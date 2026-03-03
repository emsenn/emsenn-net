// @ts-ignore
import randomPageScript from "./scripts/randompage.inline"
import styles from "./styles/randomPageButton.scss"
import { QuartzComponent, QuartzComponentConstructor, QuartzComponentProps } from "./types"
import { classNames } from "../util/lang"

const RandomPageButton: QuartzComponent = ({ displayClass }: QuartzComponentProps) => {
  return (
    <button class={classNames(displayClass, "random-page-btn")} aria-label="Random page">
      <title>Random page</title>
      <svg
        xmlns="http://www.w3.org/2000/svg"
        width="18"
        height="18"
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        stroke-width="2"
        stroke-linecap="round"
        stroke-linejoin="round"
      >
        <polyline points="16 3 21 3 21 8"></polyline>
        <line x1="4" y1="20" x2="21" y2="3"></line>
        <polyline points="21 16 21 21 16 21"></polyline>
        <line x1="15" y1="15" x2="21" y2="21"></line>
        <line x1="4" y1="4" x2="9" y2="9"></line>
      </svg>
    </button>
  )
}

RandomPageButton.afterDOMLoaded = randomPageScript
RandomPageButton.css = styles

export default (() => RandomPageButton) satisfies QuartzComponentConstructor
