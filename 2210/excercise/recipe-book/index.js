const express = require("express");
const mongoose = require("mongoose");
const app = express();
app.use(express.json());

mongoose.connect("mongodb://recipe-database:27017/recipes", {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

const recipeSchema = new mongoose.Schema({
  title: String,
  ingredients: [String],
  instructions: String,
});
const Recipe = mongoose.model("Recipe", recipeSchema);

app.post("/recipes", async (req, res) => {
  const recipe = new Recipe(req.body);
  await recipe.save();
  res.status(201).send(recipe);
});

app.get("/recipes", async (req, res) => {
  const recipes = await Recipe.find();
  res.send(recipes);
});

app.listen(3000, () => console.log("Recipe Book App listening on port 3000"));
