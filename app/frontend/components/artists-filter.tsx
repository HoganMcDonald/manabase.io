import { X } from "lucide-react"
import type { FC } from "react"
import { useState } from "react"

import { Badge } from "@/components/ui/badge"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"

interface ArtistsFilterProps {
  selectedArtists: string[]
  onArtistsChange: (artists: string[]) => void
}

export const ArtistsFilter: FC<ArtistsFilterProps> = ({
  selectedArtists,
  onArtistsChange,
}) => {
  const [inputValue, setInputValue] = useState("")

  const handleKeyDown = (e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.key === "Enter" && inputValue.trim()) {
      e.preventDefault()
      const artistName = inputValue.trim()
      if (!selectedArtists.includes(artistName)) {
        onArtistsChange([...selectedArtists, artistName])
      }
      setInputValue("")
    }
  }

  const removeArtist = (artistToRemove: string) => {
    onArtistsChange(selectedArtists.filter((a) => a !== artistToRemove))
  }

  return (
    <div className="space-y-3">
      <div>
        <Label className="text-sm font-medium">Artists</Label>
        <p className="text-xs text-muted-foreground">
          Enter artist names and press Enter
        </p>
      </div>

      <Input
        type="text"
        placeholder="Type artist name..."
        value={inputValue}
        onChange={(e) => setInputValue(e.target.value)}
        onKeyDown={handleKeyDown}
        className="h-8"
      />

      {selectedArtists.length > 0 && (
        <div className="flex flex-wrap gap-2">
          {selectedArtists.map((artist) => (
            <Badge key={artist} variant="secondary" className="gap-1">
              {artist}
              <button
                type="button"
                onClick={() => removeArtist(artist)}
                className="hover:text-destructive"
              >
                <X className="size-3" />
              </button>
            </Badge>
          ))}
        </div>
      )}
    </div>
  )
}
