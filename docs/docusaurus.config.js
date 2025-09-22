// @ts-check
// `@type` JSDoc annotations allow editor autocompletion and type checking
// (when paired with `@ts-check`).
// There are various equivalent ways to declare your Docusaurus config.
// See: https://docusaurus.io/docs/api/docusaurus-config

import { themes as prismThemes } from "prism-react-renderer";

// This runs in Node.js - Don't use client-side code here (browser APIs, JSX...)

/** @type {import('@docusaurus/types').Config} */
const config = {
  title: "QTick Documentation",
  tagline: "Smart QR Attendance Tracking - Simple, Fast, Reliable",
  favicon: "img/favicon.ico",

  // Future flags, see https://docusaurus.io/docs/api/docusaurus-config#future
  future: {
    v4: true, // Improve compatibility with the upcoming Docusaurus v4
  },

  // Set the production url of your site here
  url: "https://docs.qtick.aadish.dev",
  // Set the /<baseUrl>/ pathname under which your site is served
  // For GitHub pages deployment, it is often '/<projectName>/'
  baseUrl: "/",

  // GitHub pages deployment config.
  // If you aren't using GitHub pages, you don't need these.
  organizationName: "aadishsamir123", // Usually your GitHub org/user name.
  projectName: "asdev-qtick", // Usually your repo name.

  onBrokenLinks: "throw",
  onBrokenMarkdownLinks: "warn",

  // Even if you don't use internationalization, you can use this field to set
  // useful metadata like html lang. For example, if your site is Chinese, you
  // may want to replace "en" with "zh-Hans".
  i18n: {
    defaultLocale: "en",
    locales: ["en"],
  },

  presets: [
    [
      "classic",
      /** @type {import('@docusaurus/preset-classic').Options} */
      ({
        docs: {
          sidebarPath: "./sidebars.js",
          // Please change this to your repo.
          // Remove this to remove the "edit this page" links.
          editUrl:
            "https://github.com/aadishsamir123/asdev-qtick/tree/main/docs/",
        },
        blog: {
          showReadingTime: true,
          feedOptions: {
            type: ["rss", "atom"],
            xslt: true,
          },
          // Please change this to your repo.
          // Remove this to remove the "edit this page" links.
          editUrl:
            "https://github.com/aadishsamir123/asdev-qtick/tree/main/docs/",
          // Useful options to enforce blogging best practices
          onInlineTags: "warn",
          onInlineAuthors: "warn",
          onUntruncatedBlogPosts: "warn",
        },
        theme: {
          customCss: "./src/css/custom.css",
        },
      }),
    ],
  ],

  themeConfig:
    /** @type {import('@docusaurus/preset-classic').ThemeConfig} */
    ({
      // Replace with your project's social card
      image: "img/qtick-logo.png",
      navbar: {
        title: "QTick",
        logo: {
          alt: "QTick Logo",
          src: "img/qtick-logo.png",
          srcDark: "img/qtick-logo.png",
        },
        items: [
          {
            type: "docSidebar",
            sidebarId: "tutorialSidebar",
            position: "left",
            label: "Documentation",
          },
          {
            href: "https://github.com/aadishsamir123/asdev-qtick",
            label: "GitHub",
            position: "right",
          },
          {
            href: "https://github.com/aadishsamir123/asdev-qtick/releases",
            label: "Download",
            position: "right",
          },
        ],
      },
      footer: {
        style: "dark",
        links: [
          {
            title: "Documentation",
            items: [
              {
                label: "Getting Started",
                to: "/docs/getting-started",
              },
              {
                label: "User Guide",
                to: "/docs/user-guide",
              },
              {
                label: "Features",
                to: "/docs/features",
              },
              {
                label: "Troubleshooting",
                to: "/docs/troubleshooting",
              },
            ],
          },
          {
            title: "Community",
            items: [
              {
                label: "GitHub Discussions",
                href: "https://github.com/aadishsamir123/asdev-qtick/discussions",
              },
              {
                label: "Issues",
                href: "https://github.com/aadishsamir123/asdev-qtick/issues",
              },
              {
                label: "Contributing",
                href: "https://github.com/aadishsamir123/asdev-qtick/blob/main/CONTRIBUTING.md",
              },
            ],
          },
          {
            title: "More",
            items: [
              {
                label: "Release Notes",
                to: "/blog",
              },
              {
                label: "GitHub Repository",
                href: "https://github.com/aadishsamir123/asdev-qtick",
              },
              {
                label: "Download Latest",
                href: "https://github.com/aadishsamir123/asdev-qtick/releases",
              },
            ],
          },
        ],
        copyright: `Copyright © 2025 Aadish Samir. Built with Docusaurus.`,
      },
      prism: {
        theme: prismThemes.github,
        darkTheme: prismThemes.dracula,
      },
    }),
};

export default config;
