/*
  Warnings:

  - A unique constraint covering the columns `[BranchName,CompanyID]` on the table `CompanyLocation` will be added. If there are existing duplicate values, this will fail.

*/
-- CreateIndex
CREATE UNIQUE INDEX "CompanyLocation_BranchName_CompanyID_key" ON "CompanyLocation"("BranchName", "CompanyID");
