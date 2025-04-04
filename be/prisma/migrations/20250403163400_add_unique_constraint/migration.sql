/*
  Warnings:

  - A unique constraint covering the columns `[CandidateID,JobID]` on the table `JobFavorites` will be added. If there are existing duplicate values, this will fail.

*/
-- CreateIndex
CREATE UNIQUE INDEX "JobFavorites_CandidateID_JobID_key" ON "JobFavorites"("CandidateID", "JobID");
