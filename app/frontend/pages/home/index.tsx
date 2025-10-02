import { Head, Link, usePage } from "@inertiajs/react"
import { Search } from "lucide-react"

import { CardGrid } from "@/components/card/grid"
import { SearchAutocomplete } from "@/components/search-autocomplete"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { useSearch } from "@/hooks/use-search"
import AppLayout from "@/layouts/app-layout"
import { transformSearchCardToCard } from "@/lib/types/card"
import { rootPath, signInPath, signUpPath } from "@/routes"
import type { SharedData } from "@/types"

const breadcrumbs = [
  {
    title: "Search",
    href: rootPath(),
  },
]

function SearchContent() {
  const {
    query,
    setQuery,
    searchResults,
    suggestions,
    isLoading,
    showSuggestions,
    setShowSuggestions,
    totalResults,
    handleSearch,
    handleSuggestionClick,
  } = useSearch()

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    void handleSearch()
  }

  // Transform search results to Card type for CardGrid
  const cards = searchResults.map((result) =>
    transformSearchCardToCard(result)
  )

  return (
    <div className="flex min-h-full flex-col">
      <Head title="Search Magic: The Gathering Cards" />

      <div className="flex flex-1 flex-col items-center justify-start p-6 pt-16 lg:pt-24">
        {/* Logo/Branding */}
        <div className="mb-8 text-center">
          <h1 className="text-4xl font-semibold tracking-tight lg:text-5xl">
            manabase.io
          </h1>
          <p className="text-muted-foreground mt-2 text-sm">
            Search Magic: The Gathering cards
          </p>
        </div>

        {/* Search Input */}
        <div className="relative w-full max-w-2xl">
          <form onSubmit={handleSubmit}>
            <div className="relative">
              <Search className="text-muted-foreground absolute left-3 top-1/2 h-5 w-5 -translate-y-1/2" />
              <Input
                type="text"
                placeholder="Search for cards..."
                value={query}
                onChange={(e) => setQuery(e.target.value)}
                className="h-12 pl-10 pr-4 text-base"
                autoFocus
              />
            </div>
          </form>

          {/* Autocomplete Suggestions */}
          <SearchAutocomplete
            suggestions={suggestions}
            show={showSuggestions}
            onSuggestionClick={handleSuggestionClick}
            onClose={() => setShowSuggestions(false)}
          />
        </div>

        {/* Search Results */}
        <div className="mt-8 w-full max-w-7xl">
          {isLoading && (
            <div className="text-muted-foreground text-center">
              Searching...
            </div>
          )}

          {!isLoading && totalResults > 0 && (
            <div className="mb-6">
              <p className="text-muted-foreground text-sm">
                Found {totalResults.toLocaleString()} card
                {totalResults !== 1 ? "s" : ""}
              </p>
            </div>
          )}

          {!isLoading && searchResults.length > 0 && (
            <CardGrid cards={cards} />
          )}

          {!isLoading &&
            query.length >= 2 &&
            searchResults.length === 0 &&
            totalResults === 0 && (
              <div className="text-muted-foreground text-center">
                No cards found matching &ldquo;{query}&rdquo;
              </div>
            )}
        </div>
      </div>
    </div>
  )
}

// Guest Header for non-authenticated users
function GuestHeader() {
  return (
    <header className="border-border absolute left-0 right-0 top-0 border-b bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/60">
      <div className="flex h-14 items-center justify-end gap-4 px-6">
        <Link href={signInPath()}>
          <Button variant="ghost" size="sm">
            Log in
          </Button>
        </Link>
        <Link href={signUpPath()}>
          <Button size="sm">Sign up</Button>
        </Link>
      </div>
    </header>
  )
}

export default function Home() {
  const page = usePage<SharedData>()
  const { auth } = page.props

  // If user is authenticated, wrap with AppLayout
  if (auth?.user) {
    return (
      <AppLayout breadcrumbs={breadcrumbs}>
        <SearchContent />
      </AppLayout>
    )
  }

  // Otherwise show guest layout
  return (
    <>
      <GuestHeader />
      <SearchContent />
    </>
  )
}
