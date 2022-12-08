module.exports = {
  purge: {
    content: [
      "./index.html",
      "./src/**/*.{vue,js,ts,jsx,tsx}",
      "./src/*.{vue,js,ts,jsx,tsx}",
    ],
  },
  // content: [],
  darkMode: "media", // or 'media' or 'class'
  theme: {
    extend: {
      colors: {
        arcall: {
          gray_1: "#18191D",
          gray_2: "#B4B3CE",
          gray_3: "#5A5A67",
          gray_4: "#F5F6FA",
          gray_5: "#1A1A1E",
          gray_6: "#EBEBF3",
          gray_7: "#B4B4CC",
          blue_1: "#294BFF",
          green_1: "#29CC85",
        },
      },
      // 最小宽度
      minWidth: {
        380: "23.75rem",
        752: '47rem',
      },
      maxWidth: {
        176: '11rem',
      },
      boxShadow: {
        arcall_1: "0px 10px 20px 0px rgba(41, 75, 255, 0.2)",
        arcall_2: "0px 4px 8px 0px rgba(41, 75, 255, 0.4)",
        arcall_3: "0px 4px 8px 0px rgba(180, 180, 204, 0.4)",
      },
    },
  },
  plugins: [],
};
