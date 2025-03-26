/*
  Warnings:

  - The primary key for the `JobBranches` table will be changed. If it partially fails, the table could be left without primary key constraint.
  - The required column `ID` was added to the `JobBranches` table with a prisma-level default value. This is not possible if the table is not empty. Please add this column as optional, then populate it before making it required.

*/
-- AlterTable
ALTER TABLE "JobBranches" DROP CONSTRAINT "JobBranches_pkey",
ADD COLUMN     "ID" UUID NOT NULL,
ADD CONSTRAINT "JobBranches_pkey" PRIMARY KEY ("ID");
