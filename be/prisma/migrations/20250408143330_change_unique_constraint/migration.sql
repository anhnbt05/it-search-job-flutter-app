/*
  Warnings:

  - A unique constraint covering the columns `[Type]` on the table `Notifications` will be added. If there are existing duplicate values, this will fail.

*/
-- DropIndex
DROP INDEX "Notifications_Title_Type_key";

-- AlterTable
ALTER TABLE "UserNotifications" ADD COLUMN     "Metdata" JSONB;

-- CreateIndex
CREATE UNIQUE INDEX "Notifications_Type_key" ON "Notifications"("Type");
