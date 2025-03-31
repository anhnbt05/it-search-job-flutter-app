/*
  Warnings:

  - You are about to drop the column `Benefits` on the `Jobs` table. All the data in the column will be lost.

*/
-- AlterTable
ALTER TABLE "Applications" ALTER COLUMN "ID" SET DEFAULT gen_random_uuid();

-- AlterTable
ALTER TABLE "Candidates" ALTER COLUMN "ID" SET DEFAULT gen_random_uuid();

-- AlterTable
ALTER TABLE "Companies" ALTER COLUMN "ID" SET DEFAULT gen_random_uuid();

-- AlterTable
ALTER TABLE "CompanyLocation" ALTER COLUMN "ID" SET DEFAULT gen_random_uuid();

-- AlterTable
ALTER TABLE "JobBranches" ALTER COLUMN "ID" SET DEFAULT gen_random_uuid();

-- AlterTable
ALTER TABLE "JobDescription" ALTER COLUMN "ID" SET DEFAULT gen_random_uuid();

-- AlterTable
ALTER TABLE "JobFavorites" ALTER COLUMN "ID" SET DEFAULT gen_random_uuid();

-- AlterTable
ALTER TABLE "JobRequirements" ALTER COLUMN "ID" SET DEFAULT gen_random_uuid();

-- AlterTable
ALTER TABLE "Jobs" DROP COLUMN "Benefits",
ALTER COLUMN "ID" SET DEFAULT gen_random_uuid();

-- AlterTable
ALTER TABLE "Locations" ALTER COLUMN "ID" SET DEFAULT gen_random_uuid();

-- AlterTable
ALTER TABLE "Notification" ALTER COLUMN "ID" SET DEFAULT gen_random_uuid();

-- AlterTable
ALTER TABLE "Recruiters" ALTER COLUMN "ID" SET DEFAULT gen_random_uuid();

-- AlterTable
ALTER TABLE "UserNotification" ALTER COLUMN "ID" SET DEFAULT gen_random_uuid();

-- AlterTable
ALTER TABLE "Users" ALTER COLUMN "ID" SET DEFAULT gen_random_uuid();

-- AlterTable
ALTER TABLE "WorkExperiences" ALTER COLUMN "ID" SET DEFAULT gen_random_uuid();

-- CreateTable
CREATE TABLE "JobBenefits" (
    "ID" UUID NOT NULL DEFAULT gen_random_uuid(),
    "Benefit" TEXT NOT NULL,
    "DeletedAt" TIMESTAMP(3),
    "JobID" UUID NOT NULL,

    CONSTRAINT "JobBenefits_pkey" PRIMARY KEY ("ID")
);

-- AddForeignKey
ALTER TABLE "JobBenefits" ADD CONSTRAINT "JobBenefits_JobID_fkey" FOREIGN KEY ("JobID") REFERENCES "Jobs"("ID") ON DELETE CASCADE ON UPDATE CASCADE;
