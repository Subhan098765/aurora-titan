import os
import google.generativeai as genai
import logging

class KnowledgeRetrievalAgent:
    """
    Antigravity Agent: Knowledge Retrieval (RAG/Assistant)
    Acts as an AI Copilot to answer complex operational questions.
    """
    def __init__(self):
        self.logger = logging.getLogger("Antigravity.KnowledgeAgent")
        self.api_key = os.getenv("GEMINI_API_KEY")
        if self.api_key:
            genai.configure(api_key=self.api_key)
            self.model = genai.GenerativeModel('gemini-1.5-flash')
        else:
            self.model = None

    def query(self, user_question: str, image_base64: str | None = None) -> str:
        self.logger.info(f"Knowledge Query Received: {user_question}")
        
        system_prompt = """
        You are the AURORA Deep Knowledge Assistant, a highly intelligent AI built for global disaster response.
        Provide concise, tactical, and highly professional answers to operational questions.
        Keep answers short and formatted simply.
        """
        
        if self.model:
            try:
                contents = [f"{system_prompt}\n\nUser Question: {user_question}"]
                if image_base64:
                    import base64
                    image_data = base64.b64decode(image_base64)
                    contents.append({"mime_type": "image/jpeg", "data": image_data})
                    
                response = self.model.generate_content(contents)
                return response.text
            except Exception as e:
                self.logger.error(f"Gemini API Error: {e}")
                return "System Error: Unable to reach Global Knowledge Base."
        
        # Fallback if no API key
        lower_q = user_question.lower()
        if "wildfire" in lower_q:
            return "WILD-FIRE PROTOCOL 5:\n1. Deploy FEMA Response instantly.\n2. Establish 100km exclusion zone.\n3. Request USAF Drone Fleet Alpha for aerial mapping."
        elif "flood" in lower_q or "water" in lower_q:
            return "FLOOD PROTOCOL A:\n1. Dispatch Utility Repair and UN Peacekeepers.\n2. Activate pumping stations.\n3. Issue DEFCON 3 Alert."
        else:
            return f"[Simulated AI] Analyzing database for '{user_question}'... Standard operational protocols apply. Maintain situational awareness and deploy nearest idle units."
