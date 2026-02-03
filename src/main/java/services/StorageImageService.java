package services;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Map;
import java.util.UUID;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;

import config.CloudinaryConfig;
import jakarta.servlet.http.Part;

public class StorageImageService {

    private Cloudinary cloudinary;

    public StorageImageService() {
        this.cloudinary = CloudinaryConfig.getInstance();
    }

    /**
     * Upload image from file path
     */
    public String uploadImage(String filePath) throws IOException {
        try {
            Map uploadResult = cloudinary.uploader().upload(filePath, ObjectUtils.emptyMap());
            return (String) uploadResult.get("secure_url");
        } catch (Exception e) {
            throw new IOException("Failed to upload image: " + e.getMessage(), e);
        }
    }

    /**
     * Upload image from Part (multipart file upload)
     */
    public String uploadImage(Part filePart) throws IOException {
        if (filePart == null || filePart.getSize() == 0) {
            return null;
        }

        // Validate file type
        String contentType = filePart.getContentType();
        if (contentType == null || !contentType.startsWith("image/")) {
            throw new IOException("Invalid file type. Only image files are allowed.");
        }

        // Validate file size (max 5MB)
        long fileSize = filePart.getSize();
        if (fileSize > 5 * 1024 * 1024) {
            throw new IOException("File size too large. Maximum size is 5MB.");
        }

        // Create temporary file
        String originalFileName = filePart.getSubmittedFileName();
        String fileExtension = getFileExtension(originalFileName);
        String tempFileName = UUID.randomUUID().toString() + "." + fileExtension;
        File tempFile = new File(System.getProperty("java.io.tmpdir"), tempFileName);

        try (InputStream input = filePart.getInputStream();
             FileOutputStream output = new FileOutputStream(tempFile)) {

            byte[] buffer = new byte[8192];
            int bytesRead;
            while ((bytesRead = input.read(buffer)) != -1) {
                output.write(buffer, 0, bytesRead);
            }
        }

        try {
            // Upload to Cloudinary
            Map uploadResult = cloudinary.uploader().upload(tempFile, ObjectUtils.emptyMap());
            return (String) uploadResult.get("secure_url");
        } catch (Exception e) {
            throw new IOException("Failed to upload image to Cloudinary: " + e.getMessage(), e);
        } finally {
            // Clean up temporary file
            if (tempFile.exists()) {
                tempFile.delete();
            }
        }
    }

    /**
     * Get file extension from filename
     */
    private String getFileExtension(String fileName) {
        if (fileName == null || fileName.lastIndexOf('.') == -1) {
            return "jpg"; // default extension
        }
        return fileName.substring(fileName.lastIndexOf('.') + 1).toLowerCase();
    }

    /**
     * Validate image URL
     */
    public boolean isValidImageUrl(String url) {
        if (url == null || url.trim().isEmpty()) {
            return false;
        }

        // Basic URL validation
        try {
            new java.net.URL(url);
            return url.startsWith("http://") || url.startsWith("https://");
        } catch (Exception e) {
            return false;
        }
    }
}