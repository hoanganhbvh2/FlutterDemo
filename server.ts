import express from "express";
import path from "path";
import dotenv from "dotenv";
import { GoogleGenAI, Type } from "@google/genai";
import { createServer as createViteServer } from "vite";

// Load environment variables
dotenv.config();

// Initialize Gemini API client
const ai = new GoogleGenAI({
  apiKey: process.env.GEMINI_API_KEY,
  httpOptions: {
    headers: {
      'User-Agent': 'aistudio-build',
    }
  }
});

async function startServer() {
  const app = express();
  const PORT = 3000;

  // JSON Body Parser
  app.use(express.json({ limit: '10mb' }));

  // API Route: Health Check
  app.get("/api/health", (req, res) => {
    res.json({ status: "ok" });
  });

  // API Route: Generate Learning Roadmap via Gemini 3.5 Flash
  app.post("/api/generate-roadmap", async (req, res) => {
    try {
      const { topic, description } = req.body;
      if (!topic) {
        return res.status(400).json({ error: "Topic is required" });
      }

      console.log(`Generating roadmap for topic: "${topic}"...`);

      const prompt = `
        Create a detailed, interactive visual learning roadmap for the topic: "${topic}".
        User instructions / background: "${description || 'None'}"
        
        Generate 3 to 5 key Lessons for this Topic.
        For each Lesson, generate 4 to 6 sequential and branched Steps (nodes) that a learner must take to master this Lesson.
        Each Step should be styled as a Node on a visual Graph.
        
        Provide:
        1. A list of Lessons. Each lesson has:
           - id: a unique string identifier (e.g., "lesson-1")
           - title: a short, punchy title (e.g., "Variables & Basic Types")
           - description: a summary of what this lesson covers
           - order: integer (1, 2, 3...)
        2. A list of Steps (nodes) for each Lesson. Each step has:
           - id: a unique string identifier (e.g., "step-1-1")
           - title: Vietnamese & English bilingual title (e.g., "Biến & Kiểu dữ liệu / Variables & Data types")
           - description: A concise yet highly detailed explanation of the concept, syntax, and a small markdown checklist or code snippet to help them learn
           - emoji: a single beautiful emoji representing the step (e.g., "📦", "🔢", "🔁", "🧩")
           - positionX: layout X coordinate on a virtual grid. To form a beautiful, easily readable zigzag or branched layout, space them out. Use values between 100 and 800 (e.g., 150, 450, 150, 450, etc.).
           - positionY: layout Y coordinate on a virtual grid. Increase Y for subsequent steps (e.g., 100, 220, 340, 460, 580, etc.).
           - status: Set default to "Not Started"
           - order: integer sequence
        3. A list of Edges (connections) for each Lesson to join the steps. Each edge has:
           - id: unique edge identifier (e.g., "edge-1-2")
           - from: source Step ID
           - to: destination Step ID
           
        Ensure all Vietnamese titles are highly professional, clear, and easy to understand.
      `;

      const response = await ai.models.generateContent({
        model: "gemini-3.5-flash",
        contents: prompt,
        config: {
          responseMimeType: "application/json",
          responseSchema: {
            type: Type.OBJECT,
            properties: {
              topicTitle: { type: Type.STRING, description: "Official Title of the Topic" },
              topicDescription: { type: Type.STRING, description: "Overview of the entire topic" },
              topicEmoji: { type: Type.STRING, description: "A single representative emoji for the topic" },
              lessons: {
                type: Type.ARRAY,
                items: {
                  type: Type.OBJECT,
                  properties: {
                    id: { type: Type.STRING },
                    title: { type: Type.STRING },
                    description: { type: Type.STRING },
                    order: { type: Type.INTEGER },
                    nodes: {
                      type: Type.ARRAY,
                      items: {
                        type: Type.OBJECT,
                        properties: {
                          id: { type: Type.STRING },
                          title: { type: Type.STRING },
                          description: { type: Type.STRING },
                          emoji: { type: Type.STRING },
                          positionX: { type: Type.NUMBER },
                          positionY: { type: Type.NUMBER },
                          status: { type: Type.STRING, description: "Must be 'Not Started'" },
                          order: { type: Type.INTEGER }
                        },
                        required: ["id", "title", "description", "emoji", "positionX", "positionY", "status", "order"]
                      }
                    },
                    edges: {
                      type: Type.ARRAY,
                      items: {
                        type: Type.OBJECT,
                        properties: {
                          id: { type: Type.STRING },
                          from: { type: Type.STRING },
                          to: { type: Type.STRING }
                        },
                        required: ["id", "from", "to"]
                      }
                    }
                  },
                  required: ["id", "title", "description", "order", "nodes", "edges"]
                }
              }
            },
            required: ["topicTitle", "topicDescription", "topicEmoji", "lessons"]
          }
        }
      });

      const text = response.text;
      if (!text) {
        throw new Error("No response text from Gemini");
      }

      const roadmapData = JSON.parse(text.trim());
      res.json({ success: true, data: roadmapData });
    } catch (error: any) {
      console.error("Gemini API generation error:", error);
      res.status(500).json({ error: error.message || "Failed to generate roadmap" });
    }
  });

  // Vite middleware for development
  if (process.env.NODE_ENV !== "production") {
    const vite = await createViteServer({
      server: { middlewareMode: true },
      appType: "spa",
    });
    app.use(vite.middlewares);
  } else {
    const distPath = path.join(process.cwd(), 'dist');
    app.use(express.static(distPath));
    app.get('*', (req, res) => {
      res.sendFile(path.join(distPath, 'index.html'));
    });
  }

  app.listen(PORT, "0.0.0.0", () => {
    console.log(`Server running on http://localhost:${PORT}`);
  });
}

startServer();
