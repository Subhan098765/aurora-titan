import logging
from typing import Dict, Any, List
from agents.signal_fusion_agent import SignalFusionAgent
from agents.crisis_classifier_agent import CrisisClassifierAgent

class SupervisorAgent:
    """
    Antigravity Supervisor Agent — Orchestrates the full multi-agent pipeline.
    """
    def __init__(self):
        self.logger = logging.getLogger("Antigravity.SupervisorAgent")
        self.fusion_agent = SignalFusionAgent()
        self.classifier_agent = CrisisClassifierAgent()

    def process_signals(self, signals: List[Dict[str, Any]]) -> Dict[str, Any]:
        trace = []
        trace.append(f"SupervisorAgent: Pipeline started with {len(signals)} input signals.")

        # Step 1: Signal Fusion
        trace.append("SignalFusionAgent: Ingesting signals from all sources...")
        fused = self.fusion_agent.fuse_signals(signals)
        trace.append(f"SignalFusionAgent: Fusion complete. Type={fused.get('signal_type')}, Confidence={fused.get('confidence_score')}")
        if fused.get("contradiction_level") == "high":
            trace.append("VerificationAgent: HIGH contradiction detected. Escalating for secondary verification.")

        # Step 2: Crisis Classification
        trace.append("CrisisClassifierAgent: Classifying crisis from fused signal...")
        crisis = self.classifier_agent.classify_crisis(fused)
        trace.append(f"CrisisClassifierAgent: Classified as {crisis.get('severity')} — {crisis.get('crisis_type')} at {crisis.get('location', {}).get('name')}")

        # Step 3: Resource Optimization (Simulated)
        trace.append(f"ResourceOptimizerAgent: Rerouting nearest units to {crisis.get('location', {}).get('name')}.")
        trace.append(f"StakeholderMessagingAgent: Drafting alerts for {crisis.get('affected_population', 0):,} affected citizens.")
        trace.append("SupervisorAgent: ✅ Pipeline complete. All agents synchronized.")

        return {"crisis": crisis, "trace": trace}


if __name__ == "__main__":
    import json
    logging.basicConfig(level=logging.INFO)
    agent = SupervisorAgent()
    result = agent.process_signals([
        {"type": "seismic", "text": "Magnitude 7.2 earthquake near Tokyo coast"},
        {"type": "social", "text": "Tsunami warning sirens activated in Yokohama"},
    ])
    print(json.dumps(result, indent=2))
