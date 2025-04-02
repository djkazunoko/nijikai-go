const defaultTheme = require("tailwindcss/defaultTheme");

module.exports = {
  content: [
    "./public/*.html",
    "./app/helpers/**/*.rb",
    "./app/javascript/**/*.js",
    "./app/views/**/*.{erb,haml,html,slim}",
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ["Inter var", ...defaultTheme.fontFamily.sans],
      },
      colors: {
        "base-yellow": {
          50: "#fefce8",
          100: "#fff9c2",
          200: "#ffef89",
          300: "#ffdf45",
          400: "#fdcf27",
          500: "#edb105",
          600: "#cc8802",
          700: "#a36005",
          800: "#864b0d",
          900: "#723e11",
          950: "#431f05",
        },
        "main-orange": {
          50: "#fef8ee",
          100: "#fdeed7",
          200: "#fadaae",
          300: "#f7bf7a",
          400: "#f39c49",
          500: "#ef7d20",
          600: "#e06316",
          700: "#ba4a14",
          800: "#943c18",
          900: "#773317",
          950: "#40170a",
        },
        "accent-black": {
          50: "#f7f6ef",
          100: "#ebead6",
          200: "#d9d6af",
          300: "#c3bc81",
          400: "#b1a45e",
          500: "#a29250",
          600: "#8b7743",
          700: "#705c38",
          800: "#5f4d34",
          900: "#534330",
          950: "#3a2c1f",
        },
      },
    },
  },
  plugins: [
    require("@tailwindcss/forms"),
    require("@tailwindcss/aspect-ratio"),
    require("@tailwindcss/typography"),
    require("@tailwindcss/container-queries"),
  ],
};
