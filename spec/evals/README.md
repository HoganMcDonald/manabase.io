# Search Quality Evaluation Framework

This framework provides tools to systematically evaluate and track the quality of your MTG card search functionality.

## Quick Start

```bash
# Run basic evaluation suite
rake search:eval

# Run with LLM-as-judge for semantic quality assessment
rake search:eval:with_judge

# Generate detailed report with CSV export
rake search:eval:report

# View historical results
rake search:eval:history
```

## Components

### 1. Golden Dataset (`spec/fixtures/search_evals.yml`)

Curated set of test queries with expected results. Each entry includes:
- `query`: The search query to test
- `description`: What this test validates
- `expected_results`: Array of card names that should appear in results
- `min_rank`: Maximum acceptable rank for first relevant result (default: 5)
- `relevance_threshold`: Minimum LLM judge score for semantic queries (1-5, default: 3)

**Add new test cases** by editing this file. Include diverse query types:
- Exact card names
- Natural language queries
- Mechanical searches
- MTG slang/nicknames
- Edge cases (typos, etc.)

### 2. Evaluation Metrics (`spec/support/search_eval_metrics.rb`)

Implements standard Information Retrieval metrics:
- **Precision@K**: What fraction of top K results are relevant?
- **Recall@K**: What fraction of relevant results appear in top K?
- **MRR (Mean Reciprocal Rank)**: How quickly does first relevant result appear?
- **NDCG (Normalized Discounted Cumulative Gain)**: Weighted relevance score

### 3. LLM-as-Judge (`app/services/search/eval_judge.rb`)

Uses OpenAI (via ruby_llm) to evaluate semantic relevance when ground truth is subjective.

- Rates each result 1-5 for relevance
- Provides reasoning for scores
- Useful for complex natural language queries

**Usage:**
```ruby
results = Search::CardSearch.new.search("cards that draw when creatures die")
evaluation = Search::EvalJudge.evaluate_results(
  "cards that draw when creatures die",
  results[:results],
  expected_cards: ["Midnight Reaper", "Grim Haruspex"]
)
# => {
#   results: [{rank: 1, name: "...", score: 5, reasoning: "..."}],
#   overall_quality: "...",
#   average_score: 4.2
# }
```

### 4. RSpec Eval Suite (`spec/evals/search_quality_spec.rb`)

Automated test suite that:
- Runs golden dataset through all search modes (keyword, semantic, hybrid)
- Calculates quantitative metrics
- Optionally runs LLM judge (when `USE_LLM_JUDGE=true`)
- Generates comparison reports

**Run directly:**
```bash
RUN_SEARCH_EVALS=true rspec spec/evals/search_quality_spec.rb
```

### 5. Rake Tasks (`lib/tasks/search_eval.rake`)

Convenient commands for running evaluations:

#### `rake search:eval`
Runs full eval suite with RSpec output. Good for quick checks.

#### `rake search:eval:with_judge`
Runs evals with LLM-as-judge enabled. Uses OpenAI API (may incur costs).

#### `rake search:eval:report`
Generates detailed reports:
- **Markdown report** (`tmp/search_eval_report_TIMESTAMP.md`) - Human-readable analysis
- **CSV export** (`tmp/search_eval_results_TIMESTAMP.csv`) - Data for further analysis
- **History tracking** (`tmp/search_eval_history.csv`) - Tracks metrics over time

#### `rake search:eval:history`
View historical evaluation results to track improvements over time.

## Workflow

### Initial Setup
1. Review and customize `spec/fixtures/search_evals.yml` with queries relevant to your use case
2. Ensure OpenSearch is running and indexed: `rake opensearch:status`
3. Ensure OpenAI API key is set: `echo $OPENAI_API_KEY`

### Running Evaluations

**Basic workflow:**
```bash
# Quick sanity check
rake search:eval

# Generate detailed report
rake search:eval:report

# For semantic quality assessment (uses OpenAI API)
rake search:eval:with_judge
```

### Iterating on Search Quality

1. **Baseline**: Run initial evaluation to establish baseline metrics
   ```bash
   rake search:eval:report
   ```

2. **Make changes**: Modify embedding strategy, search query building, etc.
   - Update text composition in `Search::EmbeddingService#card_to_text`
   - Adjust search query weights in `Search::CardSearch`
   - Try different embedding models

3. **Re-evaluate**: Run evals again to measure impact
   ```bash
   rake search:eval:report
   ```

4. **Compare**: Check history to see if metrics improved
   ```bash
   rake search:eval:history
   # Or compare CSV files directly
   ```

### Continuous Integration

Add to your CI pipeline:
```yaml
# .github/workflows/search_eval.yml
- name: Run search quality evals
  run: |
    rake opensearch:setup
    rake opensearch:reindex
    rake search:eval
  env:
    OPENAI_API_KEY: ${{ secrets.OPENAI_API_KEY }}
```

## Metrics Interpretation

### What "Good" Looks Like

**For exact name searches:**
- First relevant rank: 1
- Precision@10: 1.0
- MRR: 1.0

**For natural language/semantic searches:**
- First relevant rank: ≤ 10
- Precision@10: ≥ 0.3 (at least 3 relevant results in top 10)
- LLM judge average: ≥ 3.0

**For broad effect-based searches:**
- Recall@10: ≥ 0.5 (find at least half of expected results)
- NDCG@10: ≥ 0.6 (relevant results ranked higher)

### Troubleshooting Poor Results

**Low precision** (too many irrelevant results):
- Search query may be too broad
- Consider more restrictive filters
- Adjust boost values in search query

**Low recall** (missing relevant results):
- Embedding text may not capture key concepts
- Try including more card attributes in embedding
- Check if expected cards are actually indexed

**Poor LLM judge scores**:
- Results may be technically matching but semantically off
- Review embedding text composition
- Consider different embedding model

## Adding New Test Cases

Edit `spec/fixtures/search_evals.yml`:

```yaml
- query: "your new query"
  description: "What this validates"
  expected_results:
    - "Expected Card 1"
    - "Expected Card 2"
  min_rank: 10  # Optional, defaults to 5
  relevance_threshold: 3  # Optional, for LLM judge
```

Then run evals to see how your search performs!

## Cost Considerations

**LLM-as-judge** uses OpenAI API:
- Model: `gpt-4o-mini` (cheap and fast)
- Cost: ~$0.15-0.60 per 1M input tokens, ~$0.60-2.40 per 1M output tokens
- Typical eval run with 20 queries × 3 modes × 10 results = ~600 API calls
- Estimated cost: $0.05-0.20 per full eval run with judge

**Recommendations:**
- Use `rake search:eval` (without judge) for quick iterations
- Use `rake search:eval:with_judge` periodically for quality validation
- Set OpenAI usage limits in your account settings

## Future Enhancements

Potential improvements:
- [ ] Add A/B testing framework for comparing embedding strategies
- [ ] Support for weighted expected results (some cards more relevant than others)
- [ ] Automated regression detection (alert if metrics drop)
- [ ] Integration with observability tools (Datadog, etc.)
- [ ] User feedback integration (learn from actual user interactions)
- [ ] Multi-language support for internationalization
