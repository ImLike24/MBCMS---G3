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

    //tai anh len tu duong dan cua file noi bo
    public String uploadImage(String filePath) throws IOException {
        try {
            Map uploadResult = cloudinary.uploader().upload(filePath, ObjectUtils.emptyMap());
            return (String) uploadResult.get("secure_url");
        } catch (Exception e) {
            throw new IOException("Failed to upload image: " + e.getMessage(), e);
        }
    }

    //upload image tu file part (form upload)
    public String uploadImage(Part filePart) throws IOException {
        if (filePart == null || filePart.getSize() == 0) {
            return null;
        }

        // kiem tra dinh dang file
        String contentType = filePart.getContentType();
        if (contentType == null || !contentType.startsWith("image/")) {
            throw new IOException("Định dạng file không hợp lệ. Vui lòng tải lên một hình ảnh." );
        }

        // kiem tra kich co file
        long fileSize = filePart.getSize();
        if (fileSize > 5 * 1024 * 1024) {
            throw new IOException("Kích thước file vượt quá giới hạn 5MB." );
        }

        // giu mot phan file tam thoi de upload
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
            // upload den cloudinary
            Map uploadResult = cloudinary.uploader().upload(tempFile, ObjectUtils.emptyMap());
            return (String) uploadResult.get("secure_url");
        } catch (Exception e) {
            throw new IOException("Lỗi khi tải hình ảnh lên Cloudinary: " + e.getMessage(), e);
        } finally {
            // don dep file tam thoi
            if (tempFile.exists()) {
                tempFile.delete();
            }
        }
    }

    //LAY FILE MO RONG
    private String getFileExtension(String fileName) {
        if (fileName == null || fileName.lastIndexOf('.') == -1) {
            return "jpg"; // default
        }
        return fileName.substring(fileName.lastIndexOf('.') + 1).toLowerCase();
    }

    //LAY URL HINH ANH HOP LE
    public boolean isValidImageUrl(String url) {
        if (url == null || url.trim().isEmpty()) {
            return false;
        }

        // Kiem tra dinh dang URL dang can ban
        try {
            new java.net.URL(url);
            return url.startsWith("http://") || url.startsWith("https://");
        } catch (Exception e) {
            return false;
        }
    }
}