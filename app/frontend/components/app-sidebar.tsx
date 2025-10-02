import { Link, usePage } from "@inertiajs/react"
import { BookOpen, Folder, LayoutGrid, Search, Shield } from "lucide-react"

import { NavFooter } from "@/components/nav-footer"
import { NavMain } from "@/components/nav-main"
import { NavUser } from "@/components/nav-user"
import {
  Sidebar,
  SidebarContent,
  SidebarFooter,
  SidebarHeader,
  SidebarMenu,
  SidebarMenuButton,
  SidebarMenuItem,
} from "@/components/ui/sidebar"
import { dashboardPath, rootPath } from "@/routes"
import type { NavItem, SharedData } from "@/types"

import AppLogo from "./app-logo"

const footerNavItems: NavItem[] = [
  {
    title: "Repository",
    href: "https://github.com/inertia-rails/react-starter-kit",
    icon: Folder,
  },
  {
    title: "Documentation",
    href: "https://inertia-rails.dev",
    icon: BookOpen,
  },
]

export function AppSidebar() {
  const { auth } = usePage<SharedData>().props

  const mainNavItems: NavItem[] = [
    {
      title: "Search",
      href: rootPath(),
      icon: Search,
    },
    {
      title: "Dashboard",
      href: dashboardPath(),
      icon: LayoutGrid,
    },
    ...(auth?.user?.admin ? [{
      title: "Admin",
      href: "/admin/dashboard",
      icon: Shield,
    }] : []),
  ]

  return (
    <Sidebar collapsible="icon" variant="inset">
      <SidebarHeader>
        <SidebarMenu>
          <SidebarMenuItem>
            <SidebarMenuButton size="lg" asChild>
              <Link href={dashboardPath()} prefetch>
                <AppLogo />
              </Link>
            </SidebarMenuButton>
          </SidebarMenuItem>
        </SidebarMenu>
      </SidebarHeader>

      <SidebarContent>
        <NavMain items={mainNavItems} />
      </SidebarContent>

      <SidebarFooter>
        <NavFooter items={footerNavItems} className="mt-auto" />
        <NavUser />
      </SidebarFooter>
    </Sidebar>
  )
}
