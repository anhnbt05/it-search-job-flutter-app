/*
  Warnings:

  - A unique constraint covering the columns `[ResumeUrl,CandidateID,JobID]` on the table `Applications` will be added. If there are existing duplicate values, this will fail.

*/
-- CreateIndex
CREATE UNIQUE INDEX "Applications_ResumeUrl_CandidateID_JobID_key" ON "Applications"("ResumeUrl", "CandidateID", "JobID");
