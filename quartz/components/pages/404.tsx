import { i18n } from "../../i18n"
import { QuartzComponent, QuartzComponentConstructor, QuartzComponentProps } from "../types"

const NotFound: QuartzComponent = ({ cfg }: QuartzComponentProps) => {
  // If baseUrl contains a pathname after the domain, use this as the home link
  const url = new URL(`https://${cfg.baseUrl ?? "example.com"}`)
  const baseDir = url.pathname

  return (
    <article class="popover-hint">
      <h1>404 — Not Found</h1>
      <p>
        This page doesn't exist, or hasn't been written yet. If you followed a link to get here,
        it may point to something that's still in progress.
      </p>
      <p>
        You can <a href={baseDir}>return to the home page</a> or use the search to find what you're
        looking for.
      </p>
    </article>
  )
}

export default (() => NotFound) satisfies QuartzComponentConstructor
