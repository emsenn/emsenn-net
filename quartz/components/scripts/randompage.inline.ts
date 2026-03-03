let slugs: string[] | null = null

async function fetchSlugs(): Promise<string[]> {
  if (slugs) return slugs

  const response = await fetch("/sitemap.xml")
  const text = await response.text()
  const parser = new DOMParser()
  const xml = parser.parseFromString(text, "text/xml")
  const locs = xml.querySelectorAll("loc")

  slugs = Array.from(locs)
    .map((loc) => {
      try {
        const url = new URL(loc.textContent ?? "")
        return url.pathname
      } catch {
        return null
      }
    })
    .filter((path): path is string => path !== null && path !== "/")

  return slugs
}

document.addEventListener("nav", () => {
  const buttons = document.querySelectorAll(".random-page-btn")
  for (const btn of buttons) {
    const handler = async (e: Event) => {
      e.preventDefault()
      const allSlugs = await fetchSlugs()
      if (allSlugs.length === 0) return

      const currentPath = window.location.pathname
      // Pick a random slug that isn't the current page
      let attempts = 0
      let randomSlug: string
      do {
        randomSlug = allSlugs[Math.floor(Math.random() * allSlugs.length)]
        attempts++
      } while (randomSlug === currentPath && attempts < 10 && allSlugs.length > 1)

      window.spaNavigate(new URL(randomSlug, window.location.origin))
    }
    btn.addEventListener("click", handler)
    window.addCleanup(() => btn.removeEventListener("click", handler))
  }
})
