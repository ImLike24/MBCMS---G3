package config;

import java.io.InputStream;
import java.util.Properties;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;

public class CloudinaryConfig {

    private static Cloudinary cloudinary;

    static {
        try {
            Properties props = new Properties();
            InputStream iS = CloudinaryConfig.class.getClassLoader().getResourceAsStream("config.properties");

            props.load(iS);

            cloudinary = new Cloudinary(ObjectUtils.asMap(
                    "cloud_name", props.getProperty("cloudinary.cloud_name"),
                    "api_key", props.getProperty("cloudinary.api_key"),
                    "api_secret", props.getProperty("cloudinary.api_secret"),
                    "secure", true
            ));
        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("Lỗi khởi động Cloudinary", e);
        }

    }

    public static Cloudinary getInstance(){
        return cloudinary;
    }

}
