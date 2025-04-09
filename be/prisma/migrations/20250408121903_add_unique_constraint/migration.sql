/*
  Warnings:

  - A unique constraint covering the columns `[Name]` on the table `Locations` will be added. If there are existing duplicate values, this will fail.

*/
-- CreateIndex
CREATE UNIQUE INDEX "Locations_Name_key" ON "Locations"("Name");
