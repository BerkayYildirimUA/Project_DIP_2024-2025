from graphviz import Digraph

# Create a new directed graph
dot = Digraph(format='png', comment='Logical Architecture Diagram for Mun Mission')

# Define the main system and its subsystems
dot.node("Rocket", "Rocket System", shape="box3d", style="filled", color="lightblue")
dot.node("Guidance", "Guidance and Navigation Subsystem", shape="box", style="filled", color="lightyellow")
dot.node("Propulsion", "Propulsion Subsystem", shape="box", style="filled", color="lightyellow")
dot.node("SatelliteDeployment", "Satellite Deployment Subsystem", shape="box", style="filled", color="lightyellow")
dot.node("Energy", "Energy Subsystem", shape="box", style="filled", color="lightyellow")
dot.node("Landing", "Landing Subsystem", shape="box", style="filled", color="lightyellow")
dot.node("ProbeDeployment", "Probe Deployment Subsystem", shape="box", style="filled", color="lightyellow")

# Define connections between subsystems and the rocket
dot.edges([
    ("Rocket", "Guidance"),            # Rocket to Guidance and Navigation
    ("Rocket", "Propulsion"),          # Rocket to Propulsion
    ("Rocket", "SatelliteDeployment"), # Rocket to Satellite Deployment
    ("Rocket", "Energy"),              # Rocket to Energy
    ("Rocket", "Landing"),             # Rocket to Landing
    ("Rocket", "ProbeDeployment"),     # Rocket to Probe Deployment
    ("Guidance", "Propulsion"),        # Guidance to Propulsion for trajectory control
    ("Energy", "Guidance"),            # Energy powers Guidance
    ("Energy", "Propulsion"),          # Energy powers Propulsion
    ("Energy", "SatelliteDeployment"), # Energy powers Satellite Deployment
    ("Energy", "Landing"),             # Energy powers Landing
    ("Energy", "ProbeDeployment")      # Energy powers Probe Deployment
])

# Render the diagram and save to a PNG file
diagram_path = './Logical_Architecture_Diagram.png'
dot.render(diagram_path, format='png', cleanup=True)

print(f"Diagram saved as PNG at: {diagram_path}")
