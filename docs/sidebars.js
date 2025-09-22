// @ts-check

// This runs in Node.js - Don't use client-side code here (browser APIs, JSX...)

/**
 * QTick Documentation Sidebars
 * Creating a sidebar enables you to:
 - create an ordered group of docs
 - render a sidebar for each doc of that group
 - provide next/previous navigation

 @type {import('@docusaurus/plugin-content-docs').SidebarsConfig}
 */
const sidebars = {
  // Main documentation sidebar
  tutorialSidebar: [
    "intro",
    {
      type: "category",
      label: "Getting Started",
      items: ["getting-started/installation", "getting-started/first-launch"],
    },
    {
      type: "category",
      label: "User Guide",
      items: ["user-guide/overview"],
    },
  ],
};

export default sidebars;
