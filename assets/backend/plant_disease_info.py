import google.generativeai as genai
import logging
from typing import Dict, Any
import json

# Configure logging
logger = logging.getLogger(__name__)

# Configure the Gemini API with your API key
def configure_genai():
    genai.configure(api_key="YOUR_API_KEY")

class PlantDiseaseInfo:
    """Class to provide detailed information about plant diseases using Gemini API."""
    
    def __init__(self):
        """Initialize the Plant Disease Information provider."""
        logger.info("Initializing Plant Disease Information provider")
        configure_genai()
        # Initialize the Gemini model
        self.model = genai.GenerativeModel('gemini-1.5-pro')
    
    def get_disease_information(self, disease_name: str) -> Dict[str, Any]:
        """
        Use Google Generative AI to get information about the plant disease.
        
        Args:
            disease_name: The name of the plant disease to get information about
            
        Returns:
            JSON object containing detailed information about the plant disease
        """
        try:
            # Craft prompt for the AI
            prompt = f"""
            Provide detailed information about the plant disease "{disease_name}" with the following structure:
            
            1. Description: A brief 2-3 sentence explanation of what the disease is and its significance.
            2. Causes: Bullet points of the pathogen or environmental factors that cause this disease. 
            3. Symptoms: Bullet points of the visual symptoms and how they progress.
            4. Treatment: Bullet points of the most effective treatments for this disease.
            5. Prevention: Bullet points of methods to prevent this disease.
            
            Format your response as a JSON object with the following keys: "description", "causes", "symptoms", "treatment", "prevention".
            The "description" value should be a concise paragraph. All other values should be in bullet point form. Do not include any introductory text or conclusion.
            """
            
            # Generate content
            response = self.model.generate_content(prompt)
            
            # Extract and parse JSON from response
            try:
                # Find JSON content in the response
                content = response.text
                
                # Extract JSON from the response if it's wrapped in markdown code blocks
                if "```json" in content and "```" in content:
                    json_start = content.find("```json") + 7
                    json_end = content.rfind("```")
                    
                    if json_start < 0 or json_end <= 0:
                        raise ValueError("No JSON object found in response")
                        
                    json_str = content[json_start:json_end].strip()
                    disease_info = json.loads(json_str)
                else:
                    # Try to find JSON directly in the content
                    json_start = content.find('{')
                    json_end = content.rfind('}') + 1
                    
                    if json_start < 0 or json_end <= 0:
                        raise ValueError("No JSON object found in response")
                        
                    json_str = content[json_start:json_end]
                    disease_info = json.loads(json_str)
                
                # Ensure all keys exist with fallback text
                required_keys = ["description", "causes", "symptoms", "treatment", "prevention"]
                for key in required_keys:
                    if key not in disease_info or not disease_info[key]:
                        if key == "description":
                            disease_info[key] = f"Information about {disease_name} not available."
                        else:
                            disease_info[key] = [f"Information about {key} for {disease_name} not available."]
                
                return disease_info
                
            except (json.JSONDecodeError, ValueError) as e:
                logger.error(f"Error parsing JSON: {str(e)}")
                logger.debug(f"Raw response: {response.text}")
                
                # Return fallback information in case of JSON parsing error
                return {
                    "disease": disease_name,
                    "error": "Could not parse response as JSON",
                    "description": f"Information about {disease_name} could not be retrieved.",
                    "causes": ["Information not available due to a parsing error."],
                    "symptoms": ["Information not available due to a parsing error."],
                    "treatment": ["Please consult with a plant pathology expert for treatment options."],
                    "prevention": ["Regular plant care and monitoring is recommended."]
                }
            
        except Exception as e:
            logger.error(f"Error getting AI disease information: {str(e)}")
            # Return fallback information
            return {
                "disease": disease_name,
                "error": "Could not generate structured disease information",
                "description": f"Information about {disease_name} could not be retrieved.",
                "causes": ["Information not available due to an error."],
                "symptoms": ["Information not available due to an error."],
                "treatment": ["Please consult with a plant pathology expert for treatment options."],
                "prevention": ["Regular plant care and monitoring is recommended."]
            }


# Example usage
if __name__ == "__main__":
    # Create the provider
    provider = PlantDiseaseInfo()