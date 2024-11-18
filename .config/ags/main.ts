import { bar } from "widget/bar/bar";
import { menu } from "widget/menu/menu";

App.config({
  style: './style.css',
  windows: [
    bar(0),
    // bar(1),
    menu()
  ],
})
