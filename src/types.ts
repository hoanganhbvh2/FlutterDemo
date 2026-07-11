export type StepStatus = "Not Started" | "In Progress" | "Completed";

export interface Step {
  id: string;
  lessonId: string;
  title: string;
  description: string;
  emoji: string;
  positionX: number;
  positionY: number;
  status: StepStatus;
  order: number;
  createdAt?: string;
  updatedAt?: string;
}

export interface Edge {
  id: string;
  lessonId: string;
  from: string; // Step ID
  to: string;   // Step ID
}

export interface Lesson {
  id: string;
  topicId: string;
  title: string;
  description: string;
  order: number;
  nodes: Step[]; // Steps in this lesson
  edges: Edge[]; // Connections between steps in this lesson
}

export interface Topic {
  id: string;
  title: string;
  description: string;
  emoji: string;
  lessons: Lesson[];
  createdAt: string;
}
