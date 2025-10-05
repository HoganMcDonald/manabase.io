import type { FC } from "react"
import { useState } from "react"

import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"

interface PriceFilterProps {
  priceUsdMin?: number
  priceUsdMax?: number
  priceUsdFoilMin?: number
  priceUsdFoilMax?: number
  priceEurMin?: number
  priceEurMax?: number
  priceTixMin?: number
  priceTixMax?: number
  onPriceUsdMinChange: (value?: number) => void
  onPriceUsdMaxChange: (value?: number) => void
  onPriceUsdFoilMinChange: (value?: number) => void
  onPriceUsdFoilMaxChange: (value?: number) => void
  onPriceEurMinChange: (value?: number) => void
  onPriceEurMaxChange: (value?: number) => void
  onPriceTixMinChange: (value?: number) => void
  onPriceTixMaxChange: (value?: number) => void
}

export const PriceFilter: FC<PriceFilterProps> = ({
  priceUsdMin,
  priceUsdMax,
  priceUsdFoilMin,
  priceUsdFoilMax,
  priceEurMin,
  priceEurMax,
  priceTixMin,
  priceTixMax,
  onPriceUsdMinChange,
  onPriceUsdMaxChange,
  onPriceUsdFoilMinChange,
  onPriceUsdFoilMaxChange,
  onPriceEurMinChange,
  onPriceEurMaxChange,
  onPriceTixMinChange,
  onPriceTixMaxChange,
}) => {
  const [activeTab, setActiveTab] = useState("usd")

  const handleChange = (
    value: string,
    onChange: (value?: number) => void
  ) => {
    if (value === "") {
      onChange(undefined)
    } else {
      const num = Number.parseFloat(value)
      if (!Number.isNaN(num) && num >= 0) {
        onChange(num)
      }
    }
  }

  return (
    <div className="space-y-3">
      <div>
        <Label className="text-sm font-medium">Price</Label>
        <p className="text-xs text-muted-foreground">
          Filter by lowest available price
        </p>
      </div>

      <Tabs value={activeTab} onValueChange={setActiveTab}>
        <TabsList className="grid w-full grid-cols-4">
          <TabsTrigger value="usd" className="text-xs">
            USD
          </TabsTrigger>
          <TabsTrigger value="usd-foil" className="text-xs">
            USD Foil
          </TabsTrigger>
          <TabsTrigger value="eur" className="text-xs">
            EUR
          </TabsTrigger>
          <TabsTrigger value="tix" className="text-xs">
            MTGO Tix
          </TabsTrigger>
        </TabsList>

        {/* USD Tab */}
        <TabsContent value="usd" className="space-y-2">
          <div className="flex items-center gap-4">
            <div className="flex-1 space-y-1.5">
              <Label htmlFor="price-usd-min" className="text-xs text-muted-foreground">
                Minimum
              </Label>
              <div className="relative">
                <span className="absolute left-3 top-1/2 -translate-y-1/2 text-sm text-muted-foreground">
                  $
                </span>
                <Input
                  id="price-usd-min"
                  type="number"
                  min="0"
                  step="0.01"
                  placeholder="0.00"
                  value={priceUsdMin ?? ""}
                  onChange={(e) => handleChange(e.target.value, onPriceUsdMinChange)}
                  className="h-8 pl-6"
                />
              </div>
            </div>
            <div className="flex-1 space-y-1.5">
              <Label htmlFor="price-usd-max" className="text-xs text-muted-foreground">
                Maximum
              </Label>
              <div className="relative">
                <span className="absolute left-3 top-1/2 -translate-y-1/2 text-sm text-muted-foreground">
                  $
                </span>
                <Input
                  id="price-usd-max"
                  type="number"
                  min="0"
                  step="0.01"
                  placeholder="∞"
                  value={priceUsdMax ?? ""}
                  onChange={(e) => handleChange(e.target.value, onPriceUsdMaxChange)}
                  className="h-8 pl-6"
                />
              </div>
            </div>
          </div>
        </TabsContent>

        {/* USD Foil Tab */}
        <TabsContent value="usd-foil" className="space-y-2">
          <div className="flex items-center gap-4">
            <div className="flex-1 space-y-1.5">
              <Label htmlFor="price-usd-foil-min" className="text-xs text-muted-foreground">
                Minimum
              </Label>
              <div className="relative">
                <span className="absolute left-3 top-1/2 -translate-y-1/2 text-sm text-muted-foreground">
                  $
                </span>
                <Input
                  id="price-usd-foil-min"
                  type="number"
                  min="0"
                  step="0.01"
                  placeholder="0.00"
                  value={priceUsdFoilMin ?? ""}
                  onChange={(e) => handleChange(e.target.value, onPriceUsdFoilMinChange)}
                  className="h-8 pl-6"
                />
              </div>
            </div>
            <div className="flex-1 space-y-1.5">
              <Label htmlFor="price-usd-foil-max" className="text-xs text-muted-foreground">
                Maximum
              </Label>
              <div className="relative">
                <span className="absolute left-3 top-1/2 -translate-y-1/2 text-sm text-muted-foreground">
                  $
                </span>
                <Input
                  id="price-usd-foil-max"
                  type="number"
                  min="0"
                  step="0.01"
                  placeholder="∞"
                  value={priceUsdFoilMax ?? ""}
                  onChange={(e) => handleChange(e.target.value, onPriceUsdFoilMaxChange)}
                  className="h-8 pl-6"
                />
              </div>
            </div>
          </div>
        </TabsContent>

        {/* EUR Tab */}
        <TabsContent value="eur" className="space-y-2">
          <div className="flex items-center gap-4">
            <div className="flex-1 space-y-1.5">
              <Label htmlFor="price-eur-min" className="text-xs text-muted-foreground">
                Minimum
              </Label>
              <div className="relative">
                <span className="absolute left-3 top-1/2 -translate-y-1/2 text-sm text-muted-foreground">
                  €
                </span>
                <Input
                  id="price-eur-min"
                  type="number"
                  min="0"
                  step="0.01"
                  placeholder="0.00"
                  value={priceEurMin ?? ""}
                  onChange={(e) => handleChange(e.target.value, onPriceEurMinChange)}
                  className="h-8 pl-6"
                />
              </div>
            </div>
            <div className="flex-1 space-y-1.5">
              <Label htmlFor="price-eur-max" className="text-xs text-muted-foreground">
                Maximum
              </Label>
              <div className="relative">
                <span className="absolute left-3 top-1/2 -translate-y-1/2 text-sm text-muted-foreground">
                  €
                </span>
                <Input
                  id="price-eur-max"
                  type="number"
                  min="0"
                  step="0.01"
                  placeholder="∞"
                  value={priceEurMax ?? ""}
                  onChange={(e) => handleChange(e.target.value, onPriceEurMaxChange)}
                  className="h-8 pl-6"
                />
              </div>
            </div>
          </div>
        </TabsContent>

        {/* MTGO Tix Tab */}
        <TabsContent value="tix" className="space-y-2">
          <div className="flex items-center gap-4">
            <div className="flex-1 space-y-1.5">
              <Label htmlFor="price-tix-min" className="text-xs text-muted-foreground">
                Minimum
              </Label>
              <Input
                id="price-tix-min"
                type="number"
                min="0"
                step="0.01"
                placeholder="0.00"
                value={priceTixMin ?? ""}
                onChange={(e) => handleChange(e.target.value, onPriceTixMinChange)}
                className="h-8"
              />
            </div>
            <div className="flex-1 space-y-1.5">
              <Label htmlFor="price-tix-max" className="text-xs text-muted-foreground">
                Maximum
              </Label>
              <Input
                id="price-tix-max"
                type="number"
                min="0"
                step="0.01"
                placeholder="∞"
                value={priceTixMax ?? ""}
                onChange={(e) => handleChange(e.target.value, onPriceTixMaxChange)}
                className="h-8"
              />
            </div>
          </div>
        </TabsContent>
      </Tabs>
    </div>
  )
}
