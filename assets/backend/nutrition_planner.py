import gspread
from google.oauth2.service_account import Credentials
import pandas as pd
import random
import google.generativeai as genai
import os
print("Current working directory:", os.getcwd())
scopes = ["https://www.googleapis.com/auth/spreadsheets"]

creds = Credentials.from_service_account_file("assets/backend/credentials.json", scopes=scopes)

client = gspread.authorize(creds)

sheet_url = "https://docs.google.com/spreadsheets/d/1x2u92DmTs_oMGqrE_czdS7tC7AruOwTv6mN7LJIXSeg/edit?usp=sharing" # Food database Google Sheet
sheet = client.open_by_url(sheet_url).sheet1

data = sheet.get_all_records()

df = pd.DataFrame(data)

genai.configure(api_key="AIzaSyB_haRU_xiO1kHVeL4_U1YuGElZAOMGv8s") # Google Generative AI API Key

# Food Recommendation System
def recommend_foods(df, dietary_preference=None, min_sustainability_score=0):
    # Filter by dietary preference
    if dietary_preference:
        df = df[df["Dietary Tags"].str.contains(dietary_preference, case=False, na=False)]

    # Filter by minimum sustainability score
    df = df[df["Sustainability Score"] >= min_sustainability_score]

    # Sort by Sustainability Score (higher is better)
    df = df.sort_values(by="Sustainability Score", ascending=False)

    return df

# Filter allergens
def filter_allergies(df, allergies):
    for allergen in allergies:
        df = df[~df["Food Name"].str.contains(allergen, case=False, na=False)]
    return df

# Filter nutritional requirements
def filter_nutrition(df, min_protein=None, max_calories=None, min_vitamins=None):
    if max_calories:
        df = df[df["Calories"] <= max_calories]
    return df

# Generate a meal plan
def generate_meal_plan(df, dietary_preference, allergies, duration, max_calories=None, min_sustainability_score=0):
    # Filter by dietary preference and sustainability score
    filtered_foods = recommend_foods(df, dietary_preference, min_sustainability_score)

    # Filter allergens
    filtered_foods = filter_allergies(filtered_foods, allergies)

    # Filter nutritional requirements
    filtered_foods = filter_nutrition(filtered_foods, max_calories)

    # Generate meal plan
    meal_plan = {}
    meals_per_day = ["Breakfast", "Lunch", "Dinner"]

    if duration == "daily":
        meal_plan["Today:"] = {meal: random.choice(filtered_foods["Food Name"].tolist()) for meal in meals_per_day}
    elif duration == "weekly":
        for day in range(1, 8):
            meal_plan[f"Day {day}:"] = {meal: random.choice(filtered_foods["Food Name"].tolist()) for meal in meals_per_day}
    else:
        raise ValueError("Invalid duration. Choose 'daily' or 'weekly'.")

    return meal_plan

# Display the meal plan
def display_meal_plan(meal_plan):
    for day, meals in meal_plan.items():
        print(f"\n{day}")
        for meal, food in meals.items():
            print(f"{meal}: {food}")

# Generate recipe suggestions using Gemini
def suggest_recipes(ingredient, meal_type):
    model = genai.GenerativeModel("gemini-1.5-pro-latest")

    prompt = f"Suggest a {meal_type} recipe using {ingredient}. Include a brief description and step-by-step instructions. Include sustainability score and calories per serving too. Ensure no words are bolded and the ingredients are clearly marked with bullet points (\"🍳\") if necessary and the steps are numbered. Don't include asterisks as bullet points."

    try:
        # Generate recipe using Gemini
        response = model.generate_content(prompt)
        return response.text
    except Exception as e:
        return f"Failed to generate recipe: {e}"

# Main Program
def main():
    try:
        # User input
        dietary_preference = input("Enter dietary preference [Vegan, Vegetarian, Gluten-Free, Pescatarian, None]: ")
        allergies = input("Enter allergies (comma-separated): ").split(",")
        duration = input("Enter duration [daily, weekly]: ")
        max_calories = int(input("Enter maximum calories: "))
        min_sustainability_score = int(input("Enter minimum sustainability score: "))

        # Generate meal plan
        meal_plan = generate_meal_plan(df, dietary_preference, allergies, duration, max_calories, min_sustainability_score)

        # Display meal plan
        print("\n--- Meal Plan ---")
        display_meal_plan(meal_plan)

        # Suggest recipes
        print("\n--- Recipe Suggestions ---")
        for day, meals in meal_plan.items():
            print(f"\n{day}")
            for meal, food in meals.items():
                print(f"\n{meal}: {food}")
                print(suggest_recipes(food, meal))
    except ValueError as e:
        print(f"Error: {e}")
    except Exception as e:
        print(f"An unexpected error occurred: {e}")

# Run the program
if __name__ == "__main__":
    main()