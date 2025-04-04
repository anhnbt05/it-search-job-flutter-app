/*
  Warnings:

  - You are about to drop the column `CompanyID` on the `Recruiters` table. All the data in the column will be lost.

*/
-- AlterTable
ALTER TABLE "Recruiters" DROP COLUMN "CompanyID";

-- DropEnum
DROP TYPE "JobCategory";
