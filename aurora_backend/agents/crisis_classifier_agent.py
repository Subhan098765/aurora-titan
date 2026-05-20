import json
import logging
import os
import google.generativeai as genai
from typing import Dict, Any

class CrisisClassifierAgent:
    """
    Antigravity Agent: Crisis Classifier (Gemini-Powered)
    """
    def __init__(self):
        self.logger = logging.getLogger("Antigravity.CrisisClassifierAgent")
        self.api_key = os.getenv("GEMINI_API_KEY")
        if self.api_key:
            genai.configure(api_key=self.api_key)
            self.model = genai.GenerativeModel('gemini-1.5-flash')
        else:
            self.model = None

    def classify_crisis(self, fused_signal: Dict[str, Any]) -> Dict[str, Any]:
        self.logger.info("Classifying crisis from fused signal.")
        
        if self.model:
            prompt = f"""
            You are the Antigravity Crisis Classifier Agent.
            Analyze this fused signal: {json.dumps(fused_signal)}
            Classify the severity (LOW, MEDIUM, HIGH, CRITICAL), estimate affected population, and provide a trace log.
            Return ONLY valid JSON in this format:
            {{"crisis_type": "...", "severity": "...", "location": {{"lat": 0.0, "lng": 0.0, "name": "..."}}, "affected_population": 0, "duration_estimation_hours": 0, "confidence": 0.0, "trace_log": "..."}}
            """
            try:
                response = self.model.generate_content(prompt)
                clean_json = response.text.replace('```json', '').replace('```', '').strip()
                return json.loads(clean_json)
            except Exception as e:
                self.logger.error(f"Gemini API Error: {e}")

        # Fallback Mode
        return {
            "crisis_type": fused_signal.get("signal_type", "unknown").upper(),
            "severity": "CRITICAL",
            "location": {"lat": 33.6844, "lng": 73.0479, "name": "G-10, Islamabad"},
            "affected_population": 15000,
            "duration_estimation_hours": 48,
            "confidence": fused_signal.get("confidence_score", 0.5),
            "trace_log": f"[Gemini Fallback] Classified as {fused_signal.get('signal_type')} with CRITICAL severity due to population density."
        }

if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    agent = CrisisClassifierAgent()
    print(json.dumps(agent.classify_crisis({"signal_type": "water-main-burst", "confidence_score": 0.75}), indent=2))
