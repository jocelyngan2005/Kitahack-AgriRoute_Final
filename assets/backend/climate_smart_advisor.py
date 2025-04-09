import google.generativeai as genai
import os
from typing import List, Dict, Any
import json

# Configure the Gemini API with your API key
# Replace with your actual API key
def configure_genai():
    genai.configure(api_key="YOUR_API_KEY")

class ClimateSmartFarmingAdvisor:
    """Class to provide climate-smart farming recommendations using Gemini API."""
    
    def __init__(self):
        """Initialize the advisor."""
        configure_genai()
        # Initialize the Gemini model
        self.model = genai.GenerativeModel('gemini-1.5-pro')
    
    def get_climate_smart_recommendations(self, 
                                         location: str, 
                                         crop_type: str,
                                         climate_challenge: str = None) -> Dict[str, Any]:
        """
        Get climate-smart farming recommendations for a specific location and crop.
        
        Args:
            location: The geographical location (country, region, etc.)
            crop_type: The type of crop being grown
            climate_challenge: Optional specific climate challenge (drought, flooding, etc.)
            
        Returns:
            JSON object containing climate-smart farming recommendations
        """
        # Construct the prompt for Gemini
        challenge_part = f" facing {climate_challenge}" if climate_challenge else ""
        prompt = f"""
        As an agricultural expert, provide climate-smart farming recommendations for growing {crop_type} in {location}{challenge_part}.

        Focus on both adaptation strategies (how to adapt farming to changing climate conditions) and mitigation strategies (how to reduce environmental impact).
        
        Format your response as a detailed, structured JSON object with the following fields:
        
        {{
            "region": "{location}",
            "crop": "{crop_type}",
            "climate_conditions": [List of relevant climate conditions in this region],
            "adaptation_strategies": [
                {{
                    "name": "Strategy name",
                    "description": "Detailed description",
                    "benefits": ["benefit1", "benefit2"],
                    "implementation_difficulty": "Low/Medium/High",
                    "effectiveness": "Low/Medium/High"
                }}
            ],
            "mitigation_strategies": [
                {{
                    "name": "Strategy name",
                    "description": "Detailed description",
                    "benefits": ["benefit1", "benefit2"],
                    "implementation_difficulty": "Low/Medium/High",
                    "effectiveness": "Low/Medium/High"
                }}
            ],
            "sustainable_practices": [
                {{
                    "name": "Practice name",
                    "description": "Detailed description",
                    "benefits": ["benefit1", "benefit2"]
                }}
            ],
            "water_management": [Specific water management techniques],
            "soil_conservation": [Specific soil conservation techniques],
            "additional_resources": [Optional resources for farmers]
        }}
        
        Make sure to:
        1. Be regionally specific and scientifically accurate
        2. Focus on proven, practical techniques
        3. Include both traditional and modern approaches
        4. Consider small-scale and large-scale farming operations
        5. Provide locally relevant examples
        """
        
        # Generate response from Gemini
        response = self.model.generate_content(prompt)
        
        # Extract and parse JSON from response
        try:
            # Find JSON content in the response
            content = response.text
            json_start = content.find('{')
            json_end = content.rfind('}') + 1
            
            if json_start < 0 or json_end <= 0:
                raise ValueError("No JSON object found in response")
                
            json_str = content[json_start:json_end]
            recommendations = json.loads(json_str)
            return recommendations
            
        except (json.JSONDecodeError, ValueError) as e:
            # If JSON parsing fails, return a structured error message
            print(f"Error parsing JSON: {e}")
            print(f"Raw response: {response.text}")
            
            # Create a simpler response format as a fallback
            return {
                "region": location,
                "crop": crop_type,
                "error": "Could not generate structured recommendations",
                "text_response": response.text
            }
    
    def get_specific_adaptation_strategy(self, 
                                       location: str, 
                                       climate_challenge: str) -> Dict[str, Any]:
        """
        Get specific climate adaptation strategies for a location and challenge.
        
        Args:
            location: The geographical location
            climate_challenge: The specific climate challenge
            
        Returns:
            JSON object containing adaptation strategies
        """
        prompt = f"""
        As an agricultural expert, provide detailed climate adaptation strategies for farming in {location} 
        that is facing {climate_challenge}.
        
        Format your response as a JSON object with the following structure:
        
        {{
            "region": "{location}",
            "climate_challenge": "{climate_challenge}",
            "adaptation_strategies": [
                {{
                    "name": "Strategy name",
                    "description": "Detailed description",
                    "suitable_crops": ["crop1", "crop2"],
                    "implementation_steps": ["step1", "step2"],
                    "cost_level": "Low/Medium/High",
                    "effectiveness": "Low/Medium/High",
                    "time_to_implement": "Short-term/Medium-term/Long-term"
                }}
            ],
            "case_studies": [Brief example of successful implementation]
        }}
        
        Focus on practical, proven strategies that local farmers can implement.
        """
        
        # Generate response from Gemini
        response = self.model.generate_content(prompt)
        
        # Extract and parse JSON from response
        try:
            content = response.text
            json_start = content.find('{')
            json_end = content.rfind('}') + 1
            
            if json_start < 0 or json_end <= 0:
                raise ValueError("No JSON object found in response")
                
            json_str = content[json_start:json_end]
            strategies = json.loads(json_str)
            return strategies
            
        except (json.JSONDecodeError, ValueError) as e:
            print(f"Error parsing JSON: {e}")
            
            return {
                "region": location,
                "climate_challenge": climate_challenge,
                "error": "Could not generate structured strategies",
                "text_response": response.text
            }

    def get_sustainable_farming_calendar(self, 
                                        location: str, 
                                        crop_type: str) -> Dict[str, Any]:
        
        prompt = f"""
        Create a detailed climate-smart seasonal farming calendar for growing {crop_type} in {location}.
        
        Format your response as a JSON object with the following structure:
        
        {{
            "region": "{location}",
            "crop": "{crop_type}",
            "climate_profile": "Brief description of the climate in this region",
            "seasonal_calendar": [
                {{
                    "season": "Season name",
                    "months": "Which months this covers",
                    "climate_conditions": "Typical conditions during this season",
                    "farming_activities": [
                        {{
                            "activity": "Activity name",
                            "timing": "When during the season",
                            "climate_smart_practices": ["practice1", "practice2"],
                            "climate_risks": ["risk1", "risk2"],
                            "mitigation_measures": ["measure1", "measure2"]
                        }}
                    ]
                }}
            ],
            "annual_considerations": [Important year-round practices]
        }}
        
        Make sure to include region-specific seasonal variations and climate-smart practices.
        """
        
        # Generate response from Gemini
        response = self.model.generate_content(prompt)
        
        # Extract and parse JSON from response
        try:
            content = response.text
            json_start = content.find('{')
            json_end = content.rfind('}') + 1
            
            if json_start < 0 or json_end <= 0:
                raise ValueError("No JSON object found in response")
                
            json_str = content[json_start:json_end]
            calendar = json.loads(json_str)
            return calendar
            
        except (json.JSONDecodeError, ValueError) as e:
            print(f"Error parsing JSON: {e}")
            
            return {
                "region": location,
                "crop": crop_type,
                "error": "Could not generate structured calendar",
                "text_response": response.text
            }


# Example usage
if __name__ == "__main__":
    # Create the advisor
    advisor = ClimateSmartFarmingAdvisor()
  