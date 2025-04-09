/*
  Warnings:

  - A unique constraint covering the columns `[Name]` on the table `Companies` will be added. If there are existing duplicate values, this will fail.
  - A unique constraint covering the columns `[Title,Type]` on the table `Notifications` will be added. If there are existing duplicate values, this will fail.

*/
-- CreateIndex
CREATE UNIQUE INDEX "Companies_Name_key" ON "Companies"("Name");

-- CreateIndex
CREATE UNIQUE INDEX "Notifications_Title_Type_key" ON "Notifications"("Title", "Type");
