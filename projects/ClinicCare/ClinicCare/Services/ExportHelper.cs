using System;
using System.Data;
using System.IO;
using System.IO.Packaging;
using System.Text;
using System.Xml;
using iTextSharp.text;
using iTextSharp.text.pdf;
using OfficeOpenXml;
using OfficeOpenXml.Style;

namespace ClinicCare.Services
{
    /// <summary>
    /// Builds the appointment list as a real .xlsx, .pdf and .docx file
    /// (rubric ID 4). Each method returns the file bytes; streaming them to the
    /// browser is the page's job.
    ///
    ///   Excel : EPPlus 4.5 (last LGPL release)
    ///   PDF   : iTextSharp 5.5
    ///   Word  : built directly on System.IO.Packaging - see BuildWord below
    /// </summary>
    public static class ExportHelper
    {
        /// <summary>Columns exported, in order: (column name in the DataTable, heading).</summary>
        private static readonly string[,] Columns =
        {
            { "AppointmentID",   "Ref #" },
            { "PatientName",     "Patient" },
            { "PatientPhone",    "Mobile" },
            { "DoctorName",      "Doctor" },
            { "SpecialtyName",   "Specialty" },
            { "AppointmentDate", "Date" },
            { "TimeSlot",        "Time" },
            { "VisitType",       "Visit type" },
            { "Status",          "Status" }
        };

        private static int ColumnCount { get { return Columns.GetLength(0); } }

        private static string CellText(DataRow row, int column)
        {
            string name = Columns[column, 0];
            if (!row.Table.Columns.Contains(name) || row[name] == DBNull.Value) return string.Empty;

            if (name == "AppointmentDate")
                return Convert.ToDateTime(row[name]).ToString("dd MMM yyyy");

            return Convert.ToString(row[name]);
        }

        // ===================================================================
        // EXCEL - EPPlus
        // ===================================================================
        public static byte[] BuildExcel(DataTable data, string clinicName)
        {
            using (ExcelPackage package = new ExcelPackage())
            {
                ExcelWorksheet sheet = package.Workbook.Worksheets.Add("Appointments");

                // Title block
                sheet.Cells[1, 1].Value = clinicName;
                sheet.Cells[1, 1, 1, ColumnCount].Merge = true;
                sheet.Cells[1, 1].Style.Font.Bold = true;
                sheet.Cells[1, 1].Style.Font.Size = 14;

                sheet.Cells[2, 1].Value = "Appointments report - generated " + DateTime.Now.ToString("dd MMM yyyy HH:mm");
                sheet.Cells[2, 1, 2, ColumnCount].Merge = true;
                sheet.Cells[2, 1].Style.Font.Color.SetColor(System.Drawing.Color.Gray);

                const int headerRow = 4;

                for (int c = 0; c < ColumnCount; c++)
                {
                    ExcelRange cell = sheet.Cells[headerRow, c + 1];
                    cell.Value = Columns[c, 1];
                    cell.Style.Font.Bold = true;
                    cell.Style.Fill.PatternType = ExcelFillStyle.Solid;
                    cell.Style.Fill.BackgroundColor.SetColor(System.Drawing.Color.FromArgb(13, 110, 253));
                    cell.Style.Font.Color.SetColor(System.Drawing.Color.White);
                    cell.Style.Border.Bottom.Style = ExcelBorderStyle.Thin;
                }

                for (int r = 0; r < data.Rows.Count; r++)
                {
                    for (int c = 0; c < ColumnCount; c++)
                    {
                        sheet.Cells[headerRow + 1 + r, c + 1].Value = CellText(data.Rows[r], c);
                    }
                }

                if (data.Rows.Count > 0)
                {
                    sheet.Cells[headerRow, 1, headerRow + data.Rows.Count, ColumnCount].AutoFitColumns();
                }

                // Freeze the header so long lists stay readable.
                sheet.View.FreezePanes(headerRow + 1, 1);

                return package.GetAsByteArray();
            }
        }

        // ===================================================================
        // PDF - iTextSharp 5
        // ===================================================================
        public static byte[] BuildPdf(DataTable data, string clinicName)
        {
            using (MemoryStream stream = new MemoryStream())
            {
                // Landscape: nine columns do not fit portrait A4.
                Document document = new Document(PageSize.A4.Rotate(), 28f, 28f, 28f, 28f);
                PdfWriter.GetInstance(document, stream).CloseStream = false;
                document.Open();

                Font titleFont = FontFactory.GetFont(FontFactory.HELVETICA_BOLD, 16f, BaseColor.BLACK);
                Font subFont = FontFactory.GetFont(FontFactory.HELVETICA, 9f, BaseColor.GRAY);
                Font headFont = FontFactory.GetFont(FontFactory.HELVETICA_BOLD, 9f, BaseColor.WHITE);
                Font cellFont = FontFactory.GetFont(FontFactory.HELVETICA, 9f, BaseColor.BLACK);

                document.Add(new Paragraph(clinicName, titleFont));
                document.Add(new Paragraph(
                    "Appointments report - generated " + DateTime.Now.ToString("dd MMM yyyy HH:mm"), subFont));
                document.Add(new Paragraph(" "));

                PdfPTable table = new PdfPTable(ColumnCount);
                table.WidthPercentage = 100f;

                // Explicit relative widths - without these the table overflows the
                // page and the longer names wrap badly.
                table.SetWidths(new float[] { 6f, 18f, 12f, 18f, 13f, 11f, 9f, 9f, 10f });

                BaseColor headerBg = new BaseColor(13, 110, 253);
                for (int c = 0; c < ColumnCount; c++)
                {
                    PdfPCell head = new PdfPCell(new Phrase(Columns[c, 1], headFont));
                    head.BackgroundColor = headerBg;
                    head.Padding = 5f;
                    head.HorizontalAlignment = Element.ALIGN_LEFT;
                    table.AddCell(head);
                }

                table.HeaderRows = 1;

                bool shade = false;
                foreach (DataRow row in data.Rows)
                {
                    for (int c = 0; c < ColumnCount; c++)
                    {
                        PdfPCell cell = new PdfPCell(new Phrase(CellText(row, c), cellFont));
                        cell.Padding = 4f;
                        if (shade) cell.BackgroundColor = new BaseColor(245, 247, 250);
                        table.AddCell(cell);
                    }
                    shade = !shade;
                }

                if (data.Rows.Count == 0)
                {
                    PdfPCell empty = new PdfPCell(new Phrase("No appointments to report.", cellFont));
                    empty.Colspan = ColumnCount;
                    empty.Padding = 8f;
                    table.AddCell(empty);
                }

                document.Add(table);
                document.Close();

                return stream.ToArray();
            }
        }

        // ===================================================================
        // WORD - written directly as an Open XML package
        //
        // Xceed.Words.NET (the current DocX successor) ships under a licence
        // that has to be accepted per-project and pulls in four extra
        // assemblies, so the .docx is produced here with System.IO.Packaging,
        // which is part of the .NET Framework. The result is a genuine .docx,
        // not the "HTML with a Word content type" trick.
        // ===================================================================
        public static byte[] BuildWord(DataTable data, string clinicName)
        {
            using (MemoryStream stream = new MemoryStream())
            {
                using (Package package = Package.Open(stream, FileMode.Create, FileAccess.ReadWrite))
                {
                    Uri documentUri = new Uri("/word/document.xml", UriKind.Relative);

                    PackagePart part = package.CreatePart(documentUri,
                        "application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml",
                        CompressionOption.Maximum);

                    package.CreateRelationship(documentUri, TargetMode.Internal,
                        "http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument",
                        "rId1");

                    XmlWriterSettings settings = new XmlWriterSettings { Encoding = Encoding.UTF8, Indent = false };

                    using (XmlWriter w = XmlWriter.Create(part.GetStream(FileMode.Create, FileAccess.Write), settings))
                    {
                        const string ns = "http://schemas.openxmlformats.org/wordprocessingml/2006/main";

                        w.WriteStartDocument();
                        w.WriteStartElement("w", "document", ns);
                        w.WriteStartElement("w", "body", ns);

                        WriteParagraph(w, ns, clinicName, bold: true, size: 32);
                        WriteParagraph(w, ns,
                            "Appointments report - generated " + DateTime.Now.ToString("dd MMM yyyy HH:mm"),
                            bold: false, size: 18);
                        WriteParagraph(w, ns, string.Empty, bold: false, size: 20);

                        // ---- table ----
                        w.WriteStartElement("w", "tbl", ns);

                        // Borders on every edge, otherwise Word renders a gridless table.
                        w.WriteStartElement("w", "tblPr", ns);
                        w.WriteStartElement("w", "tblBorders", ns);
                        foreach (string edge in new[] { "top", "left", "bottom", "right", "insideH", "insideV" })
                        {
                            w.WriteStartElement("w", edge, ns);
                            w.WriteAttributeString("w", "val", ns, "single");
                            w.WriteAttributeString("w", "sz", ns, "4");
                            w.WriteAttributeString("w", "color", ns, "BFBFBF");
                            w.WriteEndElement();
                        }
                        w.WriteEndElement(); // tblBorders
                        w.WriteEndElement(); // tblPr

                        WriteTableRow(w, ns, HeaderTexts(), header: true);

                        foreach (DataRow row in data.Rows)
                        {
                            string[] values = new string[ColumnCount];
                            for (int c = 0; c < ColumnCount; c++) values[c] = CellText(row, c);
                            WriteTableRow(w, ns, values, header: false);
                        }

                        w.WriteEndElement(); // tbl

                        if (data.Rows.Count == 0)
                        {
                            WriteParagraph(w, ns, "No appointments to report.", bold: false, size: 20);
                        }

                        w.WriteEndElement(); // body
                        w.WriteEndElement(); // document
                        w.WriteEndDocument();
                    }
                }

                return stream.ToArray();
            }
        }

        private static string[] HeaderTexts()
        {
            string[] heads = new string[ColumnCount];
            for (int c = 0; c < ColumnCount; c++) heads[c] = Columns[c, 1];
            return heads;
        }

        private static void WriteParagraph(XmlWriter w, string ns, string text, bool bold, int size)
        {
            w.WriteStartElement("w", "p", ns);

            w.WriteStartElement("w", "r", ns);
            w.WriteStartElement("w", "rPr", ns);
            if (bold) { w.WriteStartElement("w", "b", ns); w.WriteEndElement(); }
            w.WriteStartElement("w", "sz", ns);
            w.WriteAttributeString("w", "val", ns, size.ToString());   // half-points
            w.WriteEndElement();
            w.WriteEndElement(); // rPr

            w.WriteStartElement("w", "t", ns);
            w.WriteAttributeString("xml", "space", null, "preserve");
            w.WriteString(text ?? string.Empty);
            w.WriteEndElement(); // t

            w.WriteEndElement(); // r
            w.WriteEndElement(); // p
        }

        private static void WriteTableRow(XmlWriter w, string ns, string[] values, bool header)
        {
            w.WriteStartElement("w", "tr", ns);

            foreach (string value in values)
            {
                w.WriteStartElement("w", "tc", ns);

                if (header)
                {
                    w.WriteStartElement("w", "tcPr", ns);
                    w.WriteStartElement("w", "shd", ns);
                    w.WriteAttributeString("w", "val", ns, "clear");
                    w.WriteAttributeString("w", "fill", ns, "0D6EFD");
                    w.WriteEndElement();
                    w.WriteEndElement();
                }

                w.WriteStartElement("w", "p", ns);
                w.WriteStartElement("w", "r", ns);

                w.WriteStartElement("w", "rPr", ns);
                if (header)
                {
                    w.WriteStartElement("w", "b", ns); w.WriteEndElement();
                    w.WriteStartElement("w", "color", ns);
                    w.WriteAttributeString("w", "val", ns, "FFFFFF");
                    w.WriteEndElement();
                }
                w.WriteStartElement("w", "sz", ns);
                w.WriteAttributeString("w", "val", ns, "18");
                w.WriteEndElement();
                w.WriteEndElement(); // rPr

                w.WriteStartElement("w", "t", ns);
                w.WriteAttributeString("xml", "space", null, "preserve");
                w.WriteString(value ?? string.Empty);
                w.WriteEndElement();

                w.WriteEndElement(); // r
                w.WriteEndElement(); // p
                w.WriteEndElement(); // tc
            }

            w.WriteEndElement(); // tr
        }
    }
}
