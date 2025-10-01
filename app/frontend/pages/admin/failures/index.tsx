import { Head, Link } from '@inertiajs/react';
import { useState } from 'react';
import AppLayout from '@/layouts/app-layout';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { AlertCircle, Search, X, ChevronRight } from 'lucide-react';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';

interface FailureLog {
  id: string;
  sync_id: number;
  sync_type: string;
  timestamp: string;
  error: string;
  batch_number: number | null;
  context: {
    error_class?: string;
    card_name?: string;
    oracle_id?: string;
    card_id?: string;
    set_code?: string;
    backtrace?: string[];
    [key: string]: any;
  };
  sync_version: string | null;
}

interface ErrorSummary {
  error_class: string;
  count: number;
  recent_example: FailureLog;
  affected_syncs: string[];
}

interface FailuresProps {
  failures: FailureLog[];
  total_failures: number;
  error_summary: ErrorSummary[];
  syncs_with_failures: Array<{
    id: number;
    sync_type: string;
    failure_count: number;
    last_updated: string;
  }>;
}

export default function Failures({ failures, total_failures, error_summary, syncs_with_failures }: FailuresProps) {
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedSyncType, setSelectedSyncType] = useState<string>('all');
  const [selectedErrorType, setSelectedErrorType] = useState<string>('all');
  const [expandedFailure, setExpandedFailure] = useState<string | null>(null);

  // Filter failures
  const filteredFailures = failures.filter(failure => {
    if (selectedSyncType !== 'all' && failure.sync_type !== selectedSyncType) {
      return false;
    }
    if (selectedErrorType !== 'all' && failure.context?.error_class !== selectedErrorType) {
      return false;
    }
    if (searchTerm) {
      const search = searchTerm.toLowerCase();
      return (
        failure.error.toLowerCase().includes(search) ||
        failure.context?.card_name?.toLowerCase().includes(search) ||
        failure.context?.oracle_id?.toLowerCase().includes(search) ||
        failure.context?.card_id?.toLowerCase().includes(search)
      );
    }
    return true;
  });

  const formatTime = (timestamp: string) => {
    return new Date(timestamp).toLocaleString();
  };

  const getSyncTypeBadgeColor = (syncType: string) => {
    const colors: Record<string, string> = {
      oracle_cards: 'bg-blue-100 text-blue-800',
      rulings: 'bg-green-100 text-green-800',
      default_cards: 'bg-purple-100 text-purple-800',
      unique_artwork: 'bg-yellow-100 text-yellow-800',
      all_cards: 'bg-red-100 text-red-800',
    };
    return colors[syncType] || 'bg-gray-100 text-gray-800';
  };

  return (
    <AppLayout>
      <Head title="Sync Failures" />

      <div className="p-6 space-y-6">
        <div className="flex justify-between items-center">
          <div>
            <h1 className="text-3xl font-bold">Sync Failure Analysis</h1>
            <p className="text-muted-foreground">
              {total_failures} total failures across {syncs_with_failures.length} syncs
            </p>
          </div>
          <Link href="/admin/dashboard" className="text-sm text-muted-foreground hover:text-foreground">
            ← Back to Dashboard
          </Link>
        </div>

        {/* Error Summary */}
        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
          {error_summary.slice(0, 6).map((summary) => (
            <Card key={summary.error_class} className="cursor-pointer hover:shadow-lg transition-shadow"
                  onClick={() => setSelectedErrorType(summary.error_class)}>
              <CardHeader className="pb-3">
                <div className="flex items-center justify-between">
                  <CardTitle className="text-sm font-medium">{summary.error_class}</CardTitle>
                  <Badge variant="destructive">{summary.count}</Badge>
                </div>
              </CardHeader>
              <CardContent>
                <p className="text-xs text-muted-foreground mb-2 line-clamp-2">
                  {summary.recent_example.error}
                </p>
                <div className="flex flex-wrap gap-1">
                  {summary.affected_syncs.map(sync => (
                    <Badge key={sync} variant="outline" className="text-xs">
                      {sync.replace(/_/g, ' ')}
                    </Badge>
                  ))}
                </div>
              </CardContent>
            </Card>
          ))}
        </div>

        {/* Filters */}
        <Card>
          <CardHeader>
            <CardTitle className="text-lg">Filters</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="flex flex-wrap gap-4">
              <div className="flex-1 min-w-[200px]">
                <div className="relative">
                  <Search className="absolute left-2 top-2.5 h-4 w-4 text-muted-foreground" />
                  <Input
                    placeholder="Search errors, card names, IDs..."
                    value={searchTerm}
                    onChange={(e) => setSearchTerm(e.target.value)}
                    className="pl-8"
                  />
                </div>
              </div>

              <Select value={selectedSyncType} onValueChange={setSelectedSyncType}>
                <SelectTrigger className="w-[180px]">
                  <SelectValue placeholder="All sync types" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">All sync types</SelectItem>
                  {syncs_with_failures.map(sync => (
                    <SelectItem key={sync.sync_type} value={sync.sync_type}>
                      {sync.sync_type.replace(/_/g, ' ')} ({sync.failure_count})
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>

              <Select value={selectedErrorType} onValueChange={setSelectedErrorType}>
                <SelectTrigger className="w-[200px]">
                  <SelectValue placeholder="All error types" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">All error types</SelectItem>
                  {error_summary.map(summary => (
                    <SelectItem key={summary.error_class} value={summary.error_class}>
                      {summary.error_class} ({summary.count})
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>

              {(searchTerm || selectedSyncType !== 'all' || selectedErrorType !== 'all') && (
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => {
                    setSearchTerm('');
                    setSelectedSyncType('all');
                    setSelectedErrorType('all');
                  }}
                >
                  <X className="h-4 w-4 mr-1" />
                  Clear filters
                </Button>
              )}
            </div>

            <div className="mt-4 text-sm text-muted-foreground">
              Showing {filteredFailures.length} of {failures.length} recent failures
            </div>
          </CardContent>
        </Card>

        {/* Failures List */}
        <Card>
          <CardHeader>
            <CardTitle>Individual Failures</CardTitle>
            <CardDescription>Click on a failure to see full details</CardDescription>
          </CardHeader>
          <CardContent>
            <div className="space-y-2">
              {filteredFailures.map((failure) => (
                <div
                  key={failure.id}
                  className={`border rounded-lg transition-all ${
                    expandedFailure === failure.id ? 'ring-2 ring-primary' : ''
                  }`}
                >
                  {/* Failure Header - Always Visible */}
                  <div
                    className="px-4 py-3 cursor-pointer hover:bg-muted/50"
                    onClick={() => setExpandedFailure(expandedFailure === failure.id ? null : failure.id)}
                  >
                    <div className="flex items-start justify-between">
                      <div className="flex-1 space-y-1">
                        <div className="flex items-center gap-2">
                          <AlertCircle className="h-4 w-4 text-destructive flex-shrink-0" />
                          <span className="font-medium text-sm">
                            {failure.context?.error_class || 'Error'}
                          </span>
                          <Badge className={`text-xs ${getSyncTypeBadgeColor(failure.sync_type)}`}>
                            {failure.sync_type.replace(/_/g, ' ')}
                          </Badge>
                          {failure.batch_number && (
                            <Badge variant="outline" className="text-xs">
                              Batch #{failure.batch_number}
                            </Badge>
                          )}
                        </div>
                        <p className="text-sm text-muted-foreground line-clamp-2 ml-6">
                          {failure.error}
                        </p>
                        {failure.context?.card_name && (
                          <p className="text-xs text-muted-foreground ml-6">
                            Card: {failure.context.card_name}
                            {failure.context.set_code && ` (${failure.context.set_code})`}
                          </p>
                        )}
                      </div>
                      <div className="flex items-center gap-2">
                        <span className="text-xs text-muted-foreground">
                          {formatTime(failure.timestamp)}
                        </span>
                        <ChevronRight
                          className={`h-4 w-4 text-muted-foreground transition-transform ${
                            expandedFailure === failure.id ? 'rotate-90' : ''
                          }`}
                        />
                      </div>
                    </div>
                  </div>

                  {/* Expanded Details */}
                  {expandedFailure === failure.id && (
                    <div className="border-t px-4 py-3 bg-muted/20 space-y-3">
                      {/* Full Error Message */}
                      <div>
                        <h4 className="text-xs font-medium mb-1">Full Error Message</h4>
                        <pre className="text-xs bg-black/5 dark:bg-white/5 p-2 rounded overflow-x-auto">
                          {failure.error}
                        </pre>
                      </div>

                      {/* Context Details */}
                      {failure.context && (
                        <div className="grid gap-3 md:grid-cols-2">
                          {/* Card/Entity Info */}
                          {(failure.context.card_name || failure.context.oracle_id || failure.context.card_id) && (
                            <div>
                              <h4 className="text-xs font-medium mb-1">Entity Details</h4>
                              <div className="space-y-1">
                                {failure.context.card_name && (
                                  <div className="text-xs">
                                    <span className="text-muted-foreground">Name:</span> {failure.context.card_name}
                                  </div>
                                )}
                                {failure.context.set_code && (
                                  <div className="text-xs">
                                    <span className="text-muted-foreground">Set:</span> {failure.context.set_code}
                                  </div>
                                )}
                                {failure.context.oracle_id && (
                                  <div className="text-xs">
                                    <span className="text-muted-foreground">Oracle ID:</span>{' '}
                                    <code className="bg-muted px-1 py-0.5 rounded">{failure.context.oracle_id}</code>
                                  </div>
                                )}
                                {failure.context.card_id && (
                                  <div className="text-xs">
                                    <span className="text-muted-foreground">Card ID:</span>{' '}
                                    <code className="bg-muted px-1 py-0.5 rounded">{failure.context.card_id}</code>
                                  </div>
                                )}
                              </div>
                            </div>
                          )}

                          {/* Stack Trace */}
                          {failure.context.backtrace && (
                            <div>
                              <h4 className="text-xs font-medium mb-1">Stack Trace</h4>
                              <div className="bg-black/5 dark:bg-white/5 p-2 rounded max-h-32 overflow-y-auto">
                                {failure.context.backtrace.map((frame: string, i: number) => (
                                  <div key={i} className="font-mono text-xs leading-relaxed">
                                    {frame}
                                  </div>
                                ))}
                              </div>
                            </div>
                          )}
                        </div>
                      )}

                      {/* Additional Context */}
                      {failure.context && Object.keys(failure.context).filter(k =>
                        !['card_name', 'oracle_id', 'card_id', 'set_code', 'error_class', 'backtrace'].includes(k)
                      ).length > 0 && (
                        <div>
                          <h4 className="text-xs font-medium mb-1">Additional Context</h4>
                          <pre className="text-xs bg-black/5 dark:bg-white/5 p-2 rounded overflow-x-auto">
                            {JSON.stringify(
                              Object.fromEntries(
                                Object.entries(failure.context).filter(([k]) =>
                                  !['card_name', 'oracle_id', 'card_id', 'set_code', 'error_class', 'backtrace'].includes(k)
                                )
                              ),
                              null,
                              2
                            )}
                          </pre>
                        </div>
                      )}
                    </div>
                  )}
                </div>
              ))}

              {filteredFailures.length === 0 && (
                <div className="text-center py-8 text-muted-foreground">
                  No failures match your filters
                </div>
              )}
            </div>
          </CardContent>
        </Card>
      </div>
    </AppLayout>
  );
}