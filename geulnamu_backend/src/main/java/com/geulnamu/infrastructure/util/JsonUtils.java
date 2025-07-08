package com.geulnamu.infrastructure.util;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.http.HttpServletRequest;
import lombok.extern.slf4j.Slf4j;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.BufferedReader;

@Slf4j
public class JsonUtils {

    public static String convertObjectToJson(Object object) throws JsonProcessingException {
        if(object == null) {
            return null;
        }
        ObjectMapper mapper = new ObjectMapper();
        return mapper.writeValueAsString(object);
    }

    public JSONObject readJSONStringFromRequestBody(HttpServletRequest request) throws JSONException {
        StringBuilder json = new StringBuilder();
        String line = null;

        try {
            BufferedReader reader = request.getReader();
            while((line = reader.readLine()) != null) {
                json.append(line);
            }
        } catch (Exception e) {
            log.error("Error reading JSON string: " + e);
        }

        return new JSONObject(json.toString());
    }

}
