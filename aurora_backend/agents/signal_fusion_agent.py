import json
import logging
import os
import google.generativeai as genai
from typing import Dict, Any, List

class SignalFusionAgent:
    """
    Antigravity Agent: Signal Fusion (Gemini-Powered)
    Uses Google Gemini LLM to analyze raw signals, identify conflicts, 
    and output a fused, high-confidence crisis state.
    """
    def __init__(self):
        self.logger = logging.getLogger("Antigravity.SignalFusionAgent")
        self.api_key = os.getenv("GEMINI_API_KEY")
        if self.api_key:
            genai.configure(api_key=self.api_key)
            self.model = genai.GenerativeModel('gemini-1.5-flash')
        else:
            self.model = None
            self.logger.warning("GEMINI_API_KEY not found. Running in fallback/mock mode.")

    def fuse_signals(self, inputs: List[Dict[str, Any]]) -> Dict[str, Any]:
        self.logger.info(f"Fusing {len(inputs)} signals using AI Intelligence.")
        
        if self.model:
            # Live Gemini API mode
            prompt = f"""
            You are the Antigravity Signal Fusion Agent.
            Analyze the following live crisis signals: {json.dumps(inputs)}
            1. Identify the core event.
            2. Detect any contradictions (e.g. Flood vs Water-Main burst).
            3. Provide a fused signal type and a confidence score between 0.0 and 1.0.
            Return ONLY valid JSON in this format:
            {{"signal_type": "...", "confidence_score": 0.0, "contradiction_level": "...", "credibility_score": 0.0, "trace_log": "..."}}
            """
            try:
                response = self.model.generate_content(prompt)
                # Strip markdown code blocks if present
                clean_json = response.text.replace('```json', '').replace('```', '').strip()
                result = json.loads(clean_json)
                self.logger.info("Gemini Fusion Complete.")
                return result
            except Exception as e:
                self.logger.error(f"Gemini API Error: {e}")
                # Fallthrough to mock on error

        # Fallback / Mock Mode for Hackathon Demo
        has_flooding_signals = any("flood" in str(x).lower() for x in inputs)
        has_water_main_signals = any("water-main" in str(x).lower() for x in inputs)
        
        conflict = has_flooding_signals and has_water_main_signals
        
        return {
            "signal_type": "water-main-burst" if has_water_main_signals else "unknown",
            "confidence_score": 0.75 if conflict else 0.9,
            "contradiction_level": "high" if conflict else "low",
            "credibility_score": 0.82,
            "trace_log": "[Gemini Fallback] Fused signals from social, weather, traffic. Detected potential conflict between flood and water-main burst."
        }

if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    agent = SignalFusionAgent()
    print(json.dumps(agent.fuse_signals([{"type": "social", "text": "flooding in G-10"}, {"type": "field", "text": "water-main burst"}]), indent=2))
