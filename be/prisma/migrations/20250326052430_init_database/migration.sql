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
CREATE TYPE "JobCategory" AS ENUM ('full_stack', 'front_end', 'back_end', 'mobile', 'software_engineer', 'devops', 'data_scientist', 'ai_engineer', 'game_developer', 'cyber_security', 'ui_ux_designer', 'qa_tester', 'embedded_engineer', 'other');

-- CreateEnum
CREATE TYPE "ApplicationStatus" AS ENUM ('pending', 'accepted', 'rejected');

-- CreateTable
CREATE TABLE "Users" (
    "ID" UUID NOT NULL,
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

    CONSTRAINT "Users_pkey" PRIMARY KEY ("ID")
);

-- CreateTable
CREATE TABLE "Recruiters" (
    "ID" UUID NOT NULL,
    "Position" VARCHAR(255) NOT NULL,
    "DeletedAt" TIMESTAMP(3),
    "UserID" UUID NOT NULL,
    "CompanyID" UUID NOT NULL,

    CONSTRAINT "Recruiters_pkey" PRIMARY KEY ("ID")
);

-- CreateTable
CREATE TABLE "Candidates" (
    "ID" UUID NOT NULL,
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
    "ID" UUID NOT NULL,
    "Name" TEXT NOT NULL,
    "WebsiteUrl" TEXT,
    "LogoUrl" TEXT,
    "Description" TEXT,
    "CreatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "UpdatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Companies_pkey" PRIMARY KEY ("ID")
);

-- CreateTable
CREATE TABLE "CompanyLocation" (
    "ID" UUID NOT NULL,
    "BranchName" VARCHAR(255) NOT NULL,
    "Address" VARCHAR(255) NOT NULL,
    "CreatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "UpdatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "DeletedAt" TIMESTAMP(3),
    "CompanyID" UUID NOT NULL,
    "LocationID" UUID NOT NULL,

    CONSTRAINT "CompanyLocation_pkey" PRIMARY KEY ("ID")
);

-- CreateTable
CREATE TABLE "Locations" (
    "ID" UUID NOT NULL,
    "Name" TEXT NOT NULL,
    "Country" VARCHAR(255) NOT NULL,
    "DeletedAt" TIMESTAMP(3),

    CONSTRAINT "Locations_pkey" PRIMARY KEY ("ID")
);

-- CreateTable
CREATE TABLE "JobBranches" (
    "DeletedAt" TIMESTAMP(3),
    "CompanyLocationID" UUID NOT NULL,
    "JobID" UUID NOT NULL,

    CONSTRAINT "JobBranches_pkey" PRIMARY KEY ("CompanyLocationID","JobID")
);

-- CreateTable
CREATE TABLE "Notification" (
    "ID" UUID NOT NULL,
    "Title" TEXT NOT NULL,
    "Type" "NotificationType" NOT NULL,
    "DeletedAt" TIMESTAMP(3),

    CONSTRAINT "Notification_pkey" PRIMARY KEY ("ID")
);

-- CreateTable
CREATE TABLE "UserNotification" (
    "ID" UUID NOT NULL,
    "Content" TEXT[],
    "IsRead" BOOLEAN NOT NULL DEFAULT false,
    "CreatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "DeletedAt" TIMESTAMP(3),

    CONSTRAINT "UserNotification_pkey" PRIMARY KEY ("ID")
);

-- CreateTable
CREATE TABLE "Jobs" (
    "ID" UUID NOT NULL,
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
    "Benefits" TEXT[],
    "Level" "Level" NOT NULL,
    "Category" "JobCategory" NOT NULL,
    "DeletedAt" TIMESTAMP(3),
    "RecruiterID" UUID NOT NULL,

    CONSTRAINT "Jobs_pkey" PRIMARY KEY ("ID")
);

-- CreateTable
CREATE TABLE "Applications" (
    "ID" UUID NOT NULL,
    "ResumeUrl" TEXT NOT NULL,
    "Status" "ApplicationStatus" NOT NULL,
    "AppliedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "DeletedAt" TIMESTAMP(3),
    "CandidateID" UUID NOT NULL,
    "JobID" UUID NOT NULL,

    CONSTRAINT "Applications_pkey" PRIMARY KEY ("ID")
);

-- CreateTable
CREATE TABLE "JobDescription" (
    "ID" UUID NOT NULL,
    "Description" TEXT NOT NULL,
    "DeletedAt" TIMESTAMP(3) NOT NULL,
    "JobID" UUID NOT NULL,

    CONSTRAINT "JobDescription_pkey" PRIMARY KEY ("ID")
);

-- CreateTable
CREATE TABLE "JobRequirements" (
    "ID" UUID NOT NULL,
    "Requirement" TEXT NOT NULL,
    "DeletedAt" TIMESTAMP(3),
    "JobID" UUID NOT NULL,

    CONSTRAINT "JobRequirements_pkey" PRIMARY KEY ("ID")
);

-- CreateTable
CREATE TABLE "WorkExperiences" (
    "ID" UUID NOT NULL,
    "CompanyName" VARCHAR(255) NOT NULL,
    "CompanyLogoUrl" TEXT NOT NULL,
    "Position" VARCHAR(255) NOT NULL,
    "StartDate" TIMESTAMP(3) NOT NULL,
    "EndDate" TIMESTAMP(3),
    "Descriptions" TEXT[],
    "Location" TEXT NOT NULL,
    "JobType" "JobType" NOT NULL,

    CONSTRAINT "WorkExperiences_pkey" PRIMARY KEY ("ID")
);

-- CreateTable
CREATE TABLE "JobFavorites" (
    "ID" UUID NOT NULL,
    "SavedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "DeletedAt" TIMESTAMP(3),
    "CandidateID" UUID NOT NULL,
    "JobID" UUID NOT NULL,

    CONSTRAINT "JobFavorites_pkey" PRIMARY KEY ("ID")
);

-- CreateIndex
CREATE UNIQUE INDEX "Users_Email_key" ON "Users"("Email");

-- CreateIndex
CREATE UNIQUE INDEX "Users_PhoneNumber_key" ON "Users"("PhoneNumber");

-- CreateIndex
CREATE UNIQUE INDEX "Recruiters_UserID_key" ON "Recruiters"("UserID");

-- CreateIndex
CREATE UNIQUE INDEX "Candidates_UserID_key" ON "Candidates"("UserID");

-- AddForeignKey
ALTER TABLE "Recruiters" ADD CONSTRAINT "Recruiters_UserID_fkey" FOREIGN KEY ("UserID") REFERENCES "Users"("ID") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Recruiters" ADD CONSTRAINT "Recruiters_CompanyID_fkey" FOREIGN KEY ("CompanyID") REFERENCES "Companies"("ID") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Candidates" ADD CONSTRAINT "Candidates_UserID_fkey" FOREIGN KEY ("UserID") REFERENCES "Users"("ID") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "CompanyLocation" ADD CONSTRAINT "CompanyLocation_LocationID_fkey" FOREIGN KEY ("LocationID") REFERENCES "Locations"("ID") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "CompanyLocation" ADD CONSTRAINT "CompanyLocation_CompanyID_fkey" FOREIGN KEY ("CompanyID") REFERENCES "Companies"("ID") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "JobBranches" ADD CONSTRAINT "JobBranches_CompanyLocationID_fkey" FOREIGN KEY ("CompanyLocationID") REFERENCES "CompanyLocation"("ID") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "JobBranches" ADD CONSTRAINT "JobBranches_JobID_fkey" FOREIGN KEY ("JobID") REFERENCES "Jobs"("ID") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Jobs" ADD CONSTRAINT "Jobs_RecruiterID_fkey" FOREIGN KEY ("RecruiterID") REFERENCES "Recruiters"("ID") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Applications" ADD CONSTRAINT "Applications_CandidateID_fkey" FOREIGN KEY ("CandidateID") REFERENCES "Candidates"("ID") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Applications" ADD CONSTRAINT "Applications_JobID_fkey" FOREIGN KEY ("JobID") REFERENCES "Jobs"("ID") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "JobDescription" ADD CONSTRAINT "JobDescription_JobID_fkey" FOREIGN KEY ("JobID") REFERENCES "Jobs"("ID") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "JobRequirements" ADD CONSTRAINT "JobRequirements_JobID_fkey" FOREIGN KEY ("JobID") REFERENCES "Jobs"("ID") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "JobFavorites" ADD CONSTRAINT "JobFavorites_JobID_fkey" FOREIGN KEY ("JobID") REFERENCES "Jobs"("ID") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "JobFavorites" ADD CONSTRAINT "JobFavorites_CandidateID_fkey" FOREIGN KEY ("CandidateID") REFERENCES "Candidates"("ID") ON DELETE CASCADE ON UPDATE CASCADE;
