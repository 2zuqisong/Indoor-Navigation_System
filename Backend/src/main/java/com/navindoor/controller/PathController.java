package com.navindoor.controller;

import com.navindoor.model.Node;
import com.navindoor.service.PathService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api")
public class PathController {

    @Autowired
    PathService pathService;

    @GetMapping("/path")
    public List<Node> getPath(
            @RequestParam long start,
            @RequestParam long end) {

        return pathService.calculatePath(start, end);
    }
}
