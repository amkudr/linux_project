import java.awt.*;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import javax.imageio.ImageIO;

public class Watermark {

    public static void main(String[] args) {
        if (args.length != 1) {
            System.out.println("Usage: java Watermark <folder>");
            System.exit(1);
        }

        String folderPath = args[0]; // Path to the folder with images
        File folder = new File(folderPath);
        if (!folder.exists() || !folder.isDirectory()) {
            System.out.println("Folder not found: " + folderPath);
            System.exit(1);
        }

        // student name and ID 
        String studentName = "Anton Kudryashov";
        String studentID = "329586101";
        String studentName2 = "Elav Cohen";
        String studentID2 = "208698100";

        // Loop through all files in the given folder
        for (File file : folder.listFiles()) {
            if (file.isFile() && isImage(file)) {
                try {
                    System.out.println("Processing: " + file.getName());
                    BufferedImage image = ImageIO.read(file);

                    // Add watermark text to the image
                    Graphics2D g2d = (Graphics2D) image.getGraphics();
                    g2d.setRenderingHint(RenderingHints.KEY_TEXT_ANTIALIASING, RenderingHints.VALUE_TEXT_ANTIALIAS_ON);
                    g2d.setFont(new Font("Arial", Font.BOLD, 20));
                    g2d.setColor(new Color(255, 0, 0, 128)); // Red semi-transparent

                    // Two lines of text
                    String watermarkText1 = "Student: " + studentName + " | ID: " + studentID;
                    String watermarkText2 = "Student: " + studentName2 + " | ID: " + studentID2;

                    // Measure the width and height of the text
                    FontMetrics fm = g2d.getFontMetrics();
                    int textHeight = fm.getHeight();

                    // Calculate X and Y to center each line
                    int textWidth1 = fm.stringWidth(watermarkText1);
                    int textWidth2 = fm.stringWidth(watermarkText2);

                    int x1 = (image.getWidth() - textWidth1) / 2;
                    int x2 = (image.getWidth() - textWidth2) / 2;

                    // Center the first line higher, second line lower
                    int y1 = (image.getHeight() / 2) - (textHeight / 2);
                    int y2 = (image.getHeight() / 2) + (textHeight);

                    // Draw both lines
                    g2d.drawString(watermarkText1, x1, y1);
                    g2d.drawString(watermarkText2, x2, y2);

                    g2d.dispose();

                    // Save new image with "WATERMARK_" prefix
                    File output = file; // Overwrite the original file
                    ImageIO.write(image, "png", output);

                } catch (IOException e) {
                    System.out.println("Failed to process image: " + file.getName());
                    e.printStackTrace();
                }
            }
        }

        System.out.println("All images processed!");
    }

    // Helper method to check if the file is an image based on its extension
    private static boolean isImage(File file) {
        String[] extensions = { "png", "jpg", "jpeg", "bmp" };
        String name = file.getName().toLowerCase();
        for (String ext : extensions) {
            if (name.endsWith(ext)) {
                return true;
            }
        }
        return false;
    }
}
