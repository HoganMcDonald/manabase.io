# Scryfall Schema Analysis Summary

## Analysis Status

- ✅ **default-cards**: 110,031 objects analyzed
- ⏳ **all-cards**: Still processing (largest file)
- ✅ **oracle-cards**: 35,770 objects analyzed
- ✅ **rulings**: 72,650 objects analyzed
- ✅ **unique-artwork**: 49,364 objects analyzed

## Key Findings

### Card Object Schema (from oracle-cards)

#### Required Fields (100% occurrence)
These fields appear in every card object:
- `artist` (string)
- `booster` (boolean)
- `border_color` (string)
- `cmc` (float)
- `collector_number` (string)
- `color_identity` (array)
- `colors` (array)
- `digital` (boolean)
- `games` (array)
- `highres_image` (boolean)
- `id` (string)
- `image_status` (string)
- `lang` (string)
- `layout` (string)
- `legalities` (object)
- `name` (string)
- `object` (string)
- `oracle_id` (string)
- `oversized` (boolean)
- `prices` (object)
- `prints_search_uri` (string)
- `promo` (boolean)
- `rarity` (string)
- `released_at` (string)
- `reprint` (boolean)
- `reserved` (boolean)
- `rulings_uri` (string)
- `scryfall_set_uri` (string)
- `scryfall_uri` (string)
- `set` (string)
- `set_id` (string)
- `set_name` (string)
- `set_search_uri` (string)
- `set_type` (string)
- `set_uri` (string)
- `story_spotlight` (boolean)
- `textless` (boolean)
- `uri` (string)
- `variation` (boolean)

#### Optional Fields (< 100% occurrence)
Notable optional fields and their occurrence rates:
- `card_faces` (7.8%) - For double-sided cards
- `all_parts` (17.77%) - Related cards
- `arena_id` (26.02%)
- `artist_ids` (98.16%)
- `attraction_lights` (0.14%) - For Attraction cards
- `card_back_id` (93.07%)
- `color_indicator` (1.27%)
- `content_warning` (0.01%)
- `edhrec_rank` (55.72%)
- `finishes` (99.99%)
- `flavor_name` (0.19%)
- `flavor_text` (57.06%)
- `foil` (73.51%)
- `frame` (100%)
- `frame_effects` (7.5%)
- `full_art` (16.29%)
- `hand_modifier` (0.15%)
- `illustration_id` (96.62%)
- `image_uris` (92.2%)
- `keywords` (19.57%)
- `life_modifier` (0.15%)
- `loyalty` (1.65%)
- `mana_cost` (91.17%)
- `mtgo_foil_id` (13.84%)
- `mtgo_id` (13.84%)
- `multiverse_ids` (37.21%)
- `nonfoil` (73.51%)
- `oracle_text` (91.47%)
- `penny_rank` (23.64%)
- `power` (18.02%)
- `preview` (2.78%)
- `produced_mana` (2.85%)
- `promo_types` (27.4%)
- `tcgplayer_etched_id` (0.69%)
- `tcgplayer_id` (62.88%)
- `toughness` (18.02%)
- `type_line` (100%)
- `watermark` (15.29%)

### Rulings Schema

Rulings have a much simpler structure with only 5 fields:
- `comment` (string, 100%)
- `object` (string, 100%)
- `oracle_id` (string, 100%)
- `published_at` (string, 100%)
- `source` (string, 100%)

## Database Schema Recommendations

Based on this analysis, you'll need:

1. **Main cards table** with all required fields
2. **Optional fields table** or JSON columns for rarely-used fields
3. **Separate tables for**:
   - Card faces (for double-sided cards)
   - All parts (related cards)
   - Rulings (separate entity)
   - Prices (nested object)
   - Legalities (nested object)
   - Image URIs (nested object)

4. **Consider using JSON columns for**:
   - Arrays like `colors`, `color_identity`, `games`, `keywords`
   - Nested objects like `prices`, `legalities`, `preview`
   - Rarely-used fields (< 10% occurrence)

## Files Generated

Schema analysis files have been saved to:
- `storage/scryfall/default_cards/default-cards-schema.txt`
- `storage/scryfall/all_cards/all-cards-schema.txt` (pending)
- `storage/scryfall/oracle_cards/oracle-cards-schema.txt`
- `storage/scryfall/rulings/rulings-schema.txt`
- `storage/scryfall/unique_artwork/unique-artwork-schema.txt`

Each file contains detailed field analysis including types, occurrence rates, sample values, and nested schemas.