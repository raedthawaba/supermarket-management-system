/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './src/pages/**/*.{js,ts,jsx,tsx,mdx}',
    './src/components/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          DEFAULT: '#00BFA6',
          dark: '#00897B',
          light: '#64FFDA',
        },
        secondary: '#FF6B6B',
      },
    },
  },
  plugins: [],
}
