/*
  Warnings:

  - A unique constraint covering the columns `[CandidateID,JobID]` on the table `Applications` will be added. If there are existing duplicate values, this will fail.

*/
-- DropIndex
DROP INDEX "Applications_ResumeUrl_CandidateID_JobID_key";

-- CreateIndex
CREATE UNIQUE INDEX "Applications_CandidateID_JobID_key" ON "Applications"("CandidateID", "JobID");
