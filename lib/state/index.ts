// Zustand stores — client/UI-only state.
// Server state (remote data) goes through TanStack Query.
// Example store pattern:
//
// import { create } from 'zustand';
//
// type OnboardingState = {
//   step: number;
//   nextStep: () => void;
//   reset: () => void;
// };
//
// export const useOnboardingStore = create<OnboardingState>((set) => ({
//   step: 0,
//   nextStep: () => set((s) => ({ step: s.step + 1 })),
//   reset: () => set({ step: 0 }),
// }));

export {};
