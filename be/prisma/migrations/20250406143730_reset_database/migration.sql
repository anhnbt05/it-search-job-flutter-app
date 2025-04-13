-- CreateEnum
CREATE TYPE "UserStatus" AS ENUM ('active', 'inactive');

-- CreateEnum
CREATE TYPE "Role" AS ENUM ('admin', 'recruiter', 'candidate');

-- CreateEnum
CREATE TYPE "Level" AS ENUM ('intern', 'fresher', 'mid', 'junior', 'senior');

-- CreateEnum
CREATE TYPE "NotificationType" AS ENUM ('candidate_application_approved', 'candidate_application_rejected', 'recruiter_job_approved', 'recruiter_job_rejected', 'recruiter_new_application', 'admin_new_job_post');

-- CreateEnum
CREATE TYPE "JobType" AS ENUM ('part_time', 'full_time', 'remote', 'free_lance');

-- CreateEnum
CREATE TYPE "JobStatus" AS ENUM ('open', 'closed', 'pending', 'rejected');

-- CreateEnum
CREATE TYPE "ApplicationStatus" AS ENUM ('pending', 'accepted', 'rejected');

-- CreateTable
CREATE TABLE "Users" (
    "ID" UUID NOT NULL DEFAULT gen_random_uuid(),
    "Email" VARCHAR(255) NOT NULL,
    "Password" VARCHAR(255) NOT NULL,
    "FullName" TEXT NOT NULL,
    "AvatarUrl" TEXT,
    "PhoneNumber" VARCHAR(255) NOT NULL,
    "Status" "UserStatus" NOT NULL DEFAULT 'active',
    "CreatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "UpdatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "Role" "Role" NOT NULL,
    "DeletedAt" TIMESTAMP(3),
    "IsEmailVerified" BOOLEAN NOT NULL DEFAULT false,

    CONSTRAINT "Users_pkey" PRIMARY KEY ("ID")
);

-- CreateTable
CREATE TABLE "Recruiters" (
    "ID" UUID NOT NULL DEFAULT gen_random_uuid(),
    "Position" VARCHAR(255) NOT NULL,
    "DeletedAt" TIMESTAMP(3),
    "UserID" UUID NOT NULL,
    "CompanyLocationID" UUID NOT NULL,

    CONSTRAINT "Recruiters_pkey" PRIMARY KEY ("ID")
);

-- CreateTable
CREATE TABLE "Candidates" (
    "ID" UUID NOT NULL DEFAULT gen_random_uuid(),
    "ResumeUrl" TEXT,
    "Certifications" TEXT[],
    "Bio" TEXT,
    "Level" "Level" NOT NULL,
    "DeletedAt" TIMESTAMP(3),
    "UserID" UUID NOT NULL,

    CONSTRAINT "Candidates_pkey" PRIMARY KEY ("ID")
);

-- CreateTable
CREATE TABLE "Companies" (
    "ID" UUID NOT NULL DEFAULT gen_random_uuid(),
    "Name" TEXT NOT NULL,
    "WebsiteUrl" TEXT,
    "LogoUrl" TEXT,
    "Description" TEXT,
    "CreatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "UpdatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Companies_pkey" PRIMARY KEY ("ID")
);

-- CreateTable
CREATE TABLE "CompanyLocations" (
    "ID" UUID NOT NULL DEFAULT gen_random_uuid(),
    "BranchName" VARCHAR(255) NOT NULL,
    "Address" VARCHAR(255) NOT NULL,
    "CreatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "UpdatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "DeletedAt" TIMESTAMP(3),
    "CompanyID" UUID NOT NULL,
    "LocationID" UUID NOT NULL,

    CONSTRAINT "CompanyLocations_pkey" PRIMARY KEY ("ID")
);

-- CreateTable
CREATE TABLE "Locations" (
    "ID" UUID NOT NULL DEFAULT gen_random_uuid(),
    "Name" TEXT NOT NULL,
    "Country" VARCHAR(255) NOT NULL,
    "DeletedAt" TIMESTAMP(3),

    CONSTRAINT "Locations_pkey" PRIMARY KEY ("ID")
);

-- CreateTable
CREATE TABLE "Notifications" (
    "ID" UUID NOT NULL DEFAULT gen_random_uuid(),
    "Title" TEXT NOT NULL,
    "Type" "NotificationType" NOT NULL,
    "DeletedAt" TIMESTAMP(3),

    CONSTRAINT "Notifications_pkey" PRIMARY KEY ("ID")
);

-- CreateTable
CREATE TABLE "UserNotifications" (
    "ID" UUID NOT NULL DEFAULT gen_random_uuid(),
    "Content" TEXT[],
    "IsRead" BOOLEAN NOT NULL DEFAULT false,
    "CreatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "DeletedAt" TIMESTAMP(3),
    "UserID" UUID NOT NULL,
    "NotificationID" UUID NOT NULL,

    CONSTRAINT "UserNotifications_pkey" PRIMARY KEY ("ID")
);

-- CreateTable
CREATE TABLE "Jobs" (
    "ID" UUID NOT NULL DEFAULT gen_random_uuid(),
    "Title" TEXT NOT NULL,
    "Description" TEXT,
    "Address" VARCHAR(255) NOT NULL,
    "Salary" TEXT NOT NULL,
    "Vacancies" INTEGER NOT NULL,
    "Type" "JobType" NOT NULL,
    "WorkingTimes" TEXT NOT NULL,
    "Status" "JobStatus" NOT NULL DEFAULT 'pending',
    "PostedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "ExpiredAt" TIMESTAMP(3) NOT NULL,
    "Level" "Level" NOT NULL,
    "DeletedAt" TIMESTAMP(3),
    "RecruiterID" UUID NOT NULL,

    CONSTRAINT "Jobs_pkey" PRIMARY KEY ("ID")
);

-- CreateTable
CREATE TABLE "Applications" (
    "ID" UUID NOT NULL DEFAULT gen_random_uuid(),
    "ResumeUrl" TEXT NOT NULL,
    "Status" "ApplicationStatus" NOT NULL DEFAULT 'pending',
    "AppliedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "DeletedAt" TIMESTAMP(3),
    "CandidateID" UUID NOT NULL,
    "JobID" UUID NOT NULL,

    CONSTRAINT "Applications_pkey" PRIMARY KEY ("ID")
);

-- CreateTable
CREATE TABLE "JobDescriptions" (
    "ID" UUID NOT NULL DEFAULT gen_random_uuid(),
    "Description" TEXT NOT NULL,
    "DeletedAt" TIMESTAMP(3),
    "JobID" UUID NOT NULL,

    CONSTRAINT "JobDescriptions_pkey" PRIMARY KEY ("ID")
);

-- CreateTable
CREATE TABLE "JobRequirements" (
    "ID" UUID NOT NULL DEFAULT gen_random_uuid(),
    "Requirement" TEXT NOT NULL,
    "DeletedAt" TIMESTAMP(3),
    "JobID" UUID NOT NULL,

    CONSTRAINT "JobRequirements_pkey" PRIMARY KEY ("ID")
);

-- CreateTable
CREATE TABLE "JobBenefits" (
    "ID" UUID NOT NULL DEFAULT gen_random_uuid(),
    "Benefit" TEXT NOT NULL,
    "DeletedAt" TIMESTAMP(3),
    "JobID" UUID NOT NULL,

    CONSTRAINT "JobBenefits_pkey" PRIMARY KEY ("ID")
);

-- CreateTable
CREATE TABLE "WorkExperiences" (
    "ID" UUID NOT NULL DEFAULT gen_random_uuid(),
    "CompanyName" VARCHAR(255) NOT NULL,
    "CompanyLogoUrl" TEXT NOT NULL,
    "Position" VARCHAR(255) NOT NULL,
    "StartDate" TIMESTAMP(3) NOT NULL,
    "EndDate" TIMESTAMP(3),
    "Descriptions" TEXT[],
    "Location" TEXT NOT NULL,
    "JobType" "JobType" NOT NULL,
    "CandidateID" UUID NOT NULL,

    CONSTRAINT "WorkExperiences_pkey" PRIMARY KEY ("ID")
);

-- CreateTable
CREATE TABLE "JobFavorites" (
    "ID" UUID NOT NULL DEFAULT gen_random_uuid(),
    "SavedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "DeletedAt" TIMESTAMP(3),
    "CandidateID" UUID NOT NULL,
    "JobID" UUID NOT NULL,

    CONSTRAINT "JobFavorites_pkey" PRIMARY KEY ("ID")
);

-- CreateTable
CREATE TABLE "JobCategories" (
    "CategoryID" UUID NOT NULL,
    "JobID" UUID NOT NULL,

    CONSTRAINT "JobCategories_pkey" PRIMARY KEY ("CategoryID","JobID")
);

-- CreateTable
CREATE TABLE "Categories" (
    "ID" UUID NOT NULL DEFAULT gen_random_uuid(),
    "CategoryName" TEXT NOT NULL,
    "CreatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "UpdatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "DeletedAt" TIMESTAMP(3),

    CONSTRAINT "Categories_pkey" PRIMARY KEY ("ID")
);

-- CreateIndex
CREATE UNIQUE INDEX "Users_Email_key" ON "Users"("Email");

-- CreateIndex
CREATE UNIQUE INDEX "Users_PhoneNumber_key" ON "Users"("PhoneNumber");

-- CreateIndex
CREATE UNIQUE INDEX "Recruiters_UserID_key" ON "Recruiters"("UserID");

-- CreateIndex
CREATE UNIQUE INDEX "Recruiters_CompanyLocationID_key" ON "Recruiters"("CompanyLocationID");

-- CreateIndex
CREATE UNIQUE INDEX "Candidates_UserID_key" ON "Candidates"("UserID");

-- CreateIndex
CREATE UNIQUE INDEX "CompanyLocations_BranchName_CompanyID_key" ON "CompanyLocations"("BranchName", "CompanyID");

-- CreateIndex
CREATE UNIQUE INDEX "WorkExperiences_CompanyName_Position_CandidateID_key" ON "WorkExperiences"("CompanyName", "Position", "CandidateID");

-- CreateIndex
CREATE UNIQUE INDEX "JobFavorites_CandidateID_JobID_key" ON "JobFavorites"("CandidateID", "JobID");

-- CreateIndex
CREATE INDEX "JobCategories_CategoryID_JobID_idx" ON "JobCategories"("CategoryID", "JobID");

-- CreateIndex
CREATE UNIQUE INDEX "Categories_CategoryName_key" ON "Categories"("CategoryName");

-- AddForeignKey
ALTER TABLE "Recruiters" ADD CONSTRAINT "Recruiters_UserID_fkey" FOREIGN KEY ("UserID") REFERENCES "Users"("ID") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Recruiters" ADD CONSTRAINT "Recruiters_CompanyLocationID_fkey" FOREIGN KEY ("CompanyLocationID") REFERENCES "CompanyLocations"("ID") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Candidates" ADD CONSTRAINT "Candidates_UserID_fkey" FOREIGN KEY ("UserID") REFERENCES "Users"("ID") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "CompanyLocations" ADD CONSTRAINT "CompanyLocations_CompanyID_fkey" FOREIGN KEY ("CompanyID") REFERENCES "Companies"("ID") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "CompanyLocations" ADD CONSTRAINT "CompanyLocations_LocationID_fkey" FOREIGN KEY ("LocationID") REFERENCES "Locations"("ID") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "UserNotifications" ADD CONSTRAINT "UserNotifications_UserID_fkey" FOREIGN KEY ("UserID") REFERENCES "Users"("ID") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "UserNotifications" ADD CONSTRAINT "UserNotifications_NotificationID_fkey" FOREIGN KEY ("NotificationID") REFERENCES "Notifications"("ID") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Jobs" ADD CONSTRAINT "Jobs_RecruiterID_fkey" FOREIGN KEY ("RecruiterID") REFERENCES "Recruiters"("ID") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Applications" ADD CONSTRAINT "Applications_CandidateID_fkey" FOREIGN KEY ("CandidateID") REFERENCES "Candidates"("ID") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Applications" ADD CONSTRAINT "Applications_JobID_fkey" FOREIGN KEY ("JobID") REFERENCES "Jobs"("ID") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "JobDescriptions" ADD CONSTRAINT "JobDescriptions_JobID_fkey" FOREIGN KEY ("JobID") REFERENCES "Jobs"("ID") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "JobRequirements" ADD CONSTRAINT "JobRequirements_JobID_fkey" FOREIGN KEY ("JobID") REFERENCES "Jobs"("ID") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "JobBenefits" ADD CONSTRAINT "JobBenefits_JobID_fkey" FOREIGN KEY ("JobID") REFERENCES "Jobs"("ID") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "WorkExperiences" ADD CONSTRAINT "WorkExperiences_CandidateID_fkey" FOREIGN KEY ("CandidateID") REFERENCES "Candidates"("ID") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "JobFavorites" ADD CONSTRAINT "JobFavorites_CandidateID_fkey" FOREIGN KEY ("CandidateID") REFERENCES "Candidates"("ID") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "JobFavorites" ADD CONSTRAINT "JobFavorites_JobID_fkey" FOREIGN KEY ("JobID") REFERENCES "Jobs"("ID") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "JobCategories" ADD CONSTRAINT "JobCategories_JobID_fkey" FOREIGN KEY ("JobID") REFERENCES "Jobs"("ID") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "JobCategories" ADD CONSTRAINT "JobCategories_CategoryID_fkey" FOREIGN KEY ("CategoryID") REFERENCES "Categories"("ID") ON DELETE CASCADE ON UPDATE CASCADE;
