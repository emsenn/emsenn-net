import { i18n } from "../i18n"
import { FullSlug, getFileExtension, joinSegments, pathToRoot } from "../util/path"
import { CSSResourceToStyleElement, JSResourceToScriptElement } from "../util/resources"
import { googleFontHref, googleFontSubsetHref } from "../util/theme"
import { QuartzComponent, QuartzComponentConstructor, QuartzComponentProps } from "./types"
import { unescapeHTML } from "../util/escape"
import { CustomOgImagesEmitterName } from "../plugins/emitters/ogImage"

function buildJsonLd(
  slug: string,
  title: string,
  description: string,
  pageUrl: string,
  baseUrl: string,
  frontmatter?: Record<string, unknown>,
): object[] {
  const siteUrl = `https://${baseUrl}`
  const author = {
    "@type": "Person",
    name: "emsenn",
    url: siteUrl,
  }

  const datePublished = frontmatter?.created
    ? new Date(frontmatter.created as string).toISOString()
    : undefined
  const dateModified = frontmatter?.modified
    ? new Date(frontmatter.modified as string).toISOString()
    : datePublished

  const graphs: object[] = []

  // Site-wide WebSite schema (on index page only, to avoid repetition)
  if (slug === "index") {
    graphs.push({
      "@context": "https://schema.org",
      "@type": "WebSite",
      name: "emsenn",
      url: siteUrl,
      description:
        "Research site of emsenn — relationality, semiotics, mathematics, and Indigenous epistemologies.",
      author,
    })
  }

  // Determine page type from type: frontmatter field, falling back to slug
  const slugParts = slug.split("/")
  const contentType = frontmatter?.type as string | undefined

  // Map type: field to Schema.org @type
  const typeToSchemaType: Record<string, string> = {
    term: "DefinedTerm",
    concept: "DefinedTerm",
    person: "Person",
    lesson: "LearningResource",
    text: "Article",
    letter: "Article",
    babble: "Article",
    school: "Article",
    topic: "Article",
    skill: "Article",
    index: "CollectionPage",
  }

  let pageSchema: Record<string, unknown>
  const schemaType = contentType ? typeToSchemaType[contentType] : undefined

  if (
    schemaType === "DefinedTerm" ||
    (!schemaType && (slugParts.includes("terms") || slugParts.includes("concepts")))
  ) {
    // Term or concept definition
    pageSchema = {
      "@context": "https://schema.org",
      "@type": "DefinedTerm",
      name: title,
      description,
      url: pageUrl,
      inDefinedTermSet: {
        "@type": "DefinedTermSet",
        name: slugParts.slice(0, slugParts.indexOf("terms")).join("/") ||
              slugParts.slice(0, slugParts.indexOf("concepts")).join("/") ||
              slugParts[0],
        url: siteUrl,
      },
    }
  } else if (
    schemaType === "Person" ||
    (!schemaType && (slugParts.includes("people") ||
      (slugParts[0] === "encyclopedia" && slugParts[1] === "people")))
  ) {
    // Person page
    pageSchema = {
      "@context": "https://schema.org",
      "@type": "Person",
      name: title,
      description,
      url: pageUrl,
    }
  } else if (
    schemaType === "LearningResource" ||
    (!schemaType && slugParts.includes("curricula"))
  ) {
    // Learning resource
    pageSchema = {
      "@context": "https://schema.org",
      "@type": "LearningResource",
      name: title,
      description,
      url: pageUrl,
      author,
      inLanguage: "en",
      ...(datePublished && { datePublished }),
      ...(dateModified && { dateModified }),
    }
  } else if (schemaType === "CollectionPage") {
    // Collection / index page
    pageSchema = {
      "@context": "https://schema.org",
      "@type": "CollectionPage",
      name: title,
      description,
      url: pageUrl,
      author,
      inLanguage: "en",
    }
  } else if (slug !== "index" && slug !== "404") {
    // Default: Article (also used for text, letter, babble, school, topic, skill)
    pageSchema = {
      "@context": "https://schema.org",
      "@type": "Article",
      headline: title,
      description,
      url: pageUrl,
      author,
      publisher: author,
      inLanguage: "en",
      ...(datePublished && { datePublished }),
      ...(dateModified && { dateModified }),
    }
  } else {
    pageSchema = {}
  }

  if (Object.keys(pageSchema).length > 0) {
    graphs.push(pageSchema)
  }

  // BreadcrumbList from slug path
  if (slug !== "index" && slug !== "404" && slugParts.length > 1) {
    const breadcrumbs = slugParts.map((part, idx) => ({
      "@type": "ListItem",
      position: idx + 1,
      name: part.replace(/-/g, " "),
      item: `${siteUrl}/${slugParts.slice(0, idx + 1).join("/")}`,
    }))

    graphs.push({
      "@context": "https://schema.org",
      "@type": "BreadcrumbList",
      itemListElement: breadcrumbs,
    })
  }

  return graphs
}

export default (() => {
  const Head: QuartzComponent = ({
    cfg,
    fileData,
    externalResources,
    ctx,
  }: QuartzComponentProps) => {
    const titleSuffix = cfg.pageTitleSuffix ?? ""
    const title =
      (fileData.frontmatter?.title ?? i18n(cfg.locale).propertyDefaults.title) + titleSuffix
    const description =
      fileData.frontmatter?.socialDescription ??
      fileData.frontmatter?.description ??
      unescapeHTML(fileData.description?.trim() ?? i18n(cfg.locale).propertyDefaults.description)

    const { css, js, additionalHead } = externalResources

    const url = new URL(`https://${cfg.baseUrl ?? "example.com"}`)
    const path = url.pathname as FullSlug
    const baseDir = fileData.slug === "404" ? path : pathToRoot(fileData.slug!)
    const iconPath = joinSegments(baseDir, "static/icon.png")

    // Url of current page
    const socialUrl =
      fileData.slug === "404" ? url.toString() : joinSegments(url.toString(), fileData.slug!)

    const usesCustomOgImage = ctx.cfg.plugins.emitters.some(
      (e) => e.name === CustomOgImagesEmitterName,
    )
    const ogImageDefaultPath = `https://${cfg.baseUrl}/static/og-image.png`

    // Build JSON-LD structured data
    const jsonLdGraphs = buildJsonLd(
      fileData.slug ?? "index",
      fileData.frontmatter?.title ?? title,
      description,
      socialUrl,
      cfg.baseUrl ?? "emsenn.net",
      fileData.frontmatter as Record<string, unknown> | undefined,
    )

    return (
      <head>
        <title>{title}</title>
        <meta charSet="utf-8" />
        {cfg.theme.cdnCaching && cfg.theme.fontOrigin === "googleFonts" && (
          <>
            <link rel="preconnect" href="https://fonts.googleapis.com" />
            <link rel="preconnect" href="https://fonts.gstatic.com" />
            <link rel="stylesheet" href={googleFontHref(cfg.theme)} />
            {cfg.theme.typography.title && (
              <link rel="stylesheet" href={googleFontSubsetHref(cfg.theme, cfg.pageTitle)} />
            )}
          </>
        )}
        <link rel="preconnect" href="https://cdnjs.cloudflare.com" crossOrigin="anonymous" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />

        <meta name="og:site_name" content={cfg.pageTitle}></meta>
        <meta property="og:title" content={title} />
        <meta property="og:type" content="website" />
        <meta name="twitter:card" content="summary_large_image" />
        <meta name="twitter:title" content={title} />
        <meta name="twitter:description" content={description} />
        <meta property="og:description" content={description} />
        <meta property="og:image:alt" content={description} />

        {!usesCustomOgImage && (
          <>
            <meta property="og:image" content={ogImageDefaultPath} />
            <meta property="og:image:url" content={ogImageDefaultPath} />
            <meta name="twitter:image" content={ogImageDefaultPath} />
            <meta
              property="og:image:type"
              content={`image/${getFileExtension(ogImageDefaultPath) ?? "png"}`}
            />
          </>
        )}

        {cfg.baseUrl && (
          <>
            <meta property="twitter:domain" content={cfg.baseUrl}></meta>
            <meta property="og:url" content={socialUrl}></meta>
            <meta property="twitter:url" content={socialUrl}></meta>
          </>
        )}

        <link rel="icon" href={iconPath} />
        <meta name="description" content={description} />
        <meta name="generator" content="Quartz" />

        {jsonLdGraphs.map((graph, idx) => (
          <script
            type="application/ld+json"
            key={`jsonld-${idx}`}
            dangerouslySetInnerHTML={{ __html: JSON.stringify(graph) }}
          />
        ))}

        {css.map((resource) => CSSResourceToStyleElement(resource, true))}
        {js
          .filter((resource) => resource.loadTime === "beforeDOMReady")
          .map((res) => JSResourceToScriptElement(res, true))}
        {additionalHead.map((resource) => {
          if (typeof resource === "function") {
            return resource(fileData)
          } else {
            return resource
          }
        })}
      </head>
    )
  }

  return Head
}) satisfies QuartzComponentConstructor
