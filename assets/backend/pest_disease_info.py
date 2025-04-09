import google.generativeai as genai
import logging
from typing import Dict, Any
import json

# Configure logging
logger = logging.getLogger(__name__)

# Configure the Gemini API with your API key
def configure_genai():
    genai.configure(api_key="AIzaSyB_haRU_xiO1kHVeL4_U1YuGElZAOMGv8s")

class PestInfo:
    
    def __init__(self):
        logger.info("Initializing Pest Information provider")
        configure_genai()
        # Initialize the Gemini model
        self.model = genai.GenerativeModel('gemini-1.5-pro')
    
    def get_pest_information(self, pest_name: str) -> Dict[str, Any]:
        
        try:
            # Craft prompt for the AI
            prompt = f"""
            Provide detailed information about the pest "{pest_name}" with the following structure:
            
            1. Description: A brief 2-3 sentence explanation of what the pest is and its significance.
            2. Causes: Bullet points of the pathogen or environmental factors that cause this pest. 
            3. Symptoms: Bullet points of the visual symptoms and how they progress.
            4. Treatment: Bullet points of the most effective treatments for this pest.
            5. Prevention: Bullet points of methods to prevent this pest.
            
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
                    pest_info = json.loads(json_str)
                else:
                    # Try to find JSON directly in the content
                    json_start = content.find('{')
                    json_end = content.rfind('}') + 1
                    
                    if json_start < 0 or json_end <= 0:
                        raise ValueError("No JSON object found in response")
                        
                    json_str = content[json_start:json_end]
                    pest_info = json.loads(json_str)
                
                # Ensure all keys exist with fallback text
                required_keys = ["description", "causes", "symptoms", "treatment", "prevention"]
                for key in required_keys:
                    if key not in pest_info or not pest_info[key]:
                        if key == "description":
                            pest_info[key] = f"Information about {pest_name} not available."
                        else:
                            pest_info[key] = [f"Information about {key} for {pest_name} not available."]
                
                return pest_info
                
            except (json.JSONDecodeError, ValueError) as e:
                logger.error(f"Error parsing JSON: {str(e)}")
                logger.debug(f"Raw response: {response.text}")
                
                # Return fallback information in case of JSON parsing error
                return {
                    "pest": pest_name,
                    "error": "Could not parse response as JSON",
                    "description": f"Information about {pest_name} could not be retrieved.",
                    "causes": ["Information not available due to a parsing error."],
                    "symptoms": ["Information not available due to a parsing error."],
                    "treatment": ["Please consult with a plant pathology expert for treatment options."],
                    "prevention": ["Regular plant care and monitoring is recommended."]
                }
            
        except Exception as e:
            logger.error(f"Error getting AI pest information: {str(e)}")
            # Return fallback information
            return {
                "pest": pest_name,
                "error": "Could not generate structured pest information",
                "description": f"Information about {pest_name} could not be retrieved.",
                "causes": ["Information not available due to an error."],
                "symptoms": ["Information not available due to an error."],
                "treatment": ["Please consult with a plant pathology expert for treatment options."],
                "prevention": ["Regular plant care and monitoring is recommended."]
            }


# Example usage
if __name__ == "__main__":
    # Create the provider
    provider = PestInfo()