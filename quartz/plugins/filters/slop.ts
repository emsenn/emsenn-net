import { QuartzFilterPlugin } from "../types"

export const RemoveSlop: QuartzFilterPlugin<{}> = () => ({
  name: "RemoveSlop",
  shouldPublish(_ctx, [_tree, vfile]) {
    const slopFlag: boolean =
       vfile.data?.frontmatter?.slop === true || vfile.data?.frontmatter?.slop === "true"
    return !slopFlag
  },
})
