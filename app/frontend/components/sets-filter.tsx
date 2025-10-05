import { X } from "lucide-react"
import type { FC } from "react"
import { useState } from "react"

import { Badge } from "@/components/ui/badge"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"

interface SetsFilterProps {
  selectedSets: string[]
  onSetsChange: (sets: string[]) => void
}

export const SetsFilter: FC<SetsFilterProps> = ({
  selectedSets,
  onSetsChange,
}) => {
  const [inputValue, setInputValue] = useState("")

  const handleKeyDown = (e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.key === "Enter" && inputValue.trim()) {
      e.preventDefault()
      const setCode = inputValue.trim().toUpperCase()
      if (!selectedSets.includes(setCode)) {
        onSetsChange([...selectedSets, setCode])
      }
      setInputValue("")
    }
  }

  const removeSet = (setToRemove: string) => {
    onSetsChange(selectedSets.filter((s) => s !== setToRemove))
  }

  return (
    <div className="space-y-3">
      <div>
        <Label className="text-sm font-medium">Sets</Label>
        <p className="text-xs text-muted-foreground">
          Enter set codes (e.g., MH2, BRO) and press Enter
        </p>
      </div>

      <Input
        type="text"
        placeholder="Type set code..."
        value={inputValue}
        onChange={(e) => setInputValue(e.target.value)}
        onKeyDown={handleKeyDown}
        className="h-8"
      />

      {selectedSets.length > 0 && (
        <div className="flex flex-wrap gap-2">
          {selectedSets.map((set) => (
            <Badge key={set} variant="secondary" className="gap-1">
              {set}
              <button
                type="button"
                onClick={() => removeSet(set)}
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
