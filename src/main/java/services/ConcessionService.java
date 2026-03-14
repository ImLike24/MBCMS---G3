package services;

import models.Concession;
import repositories.Concessions;

import java.util.List;

public class ConcessionService {
    private final Concessions repo = new Concessions();

    public List<Concession> getAllConcessions() {
        return repo.getAllConcessions();
    }

    public Concession getConcessionById(int id) {
        return repo.getConcessionById(id);
    }

    public boolean addConcession(Concession c) {
        if (c.getConcessionType() == null || 
            (!"BEVERAGE".equals(c.getConcessionType()) && !"FOOD".equals(c.getConcessionType()))) {
            return false;
        }
        if (c.getPriceBase() == null || c.getPriceBase() <= 0) {
            return false;
        }

        c.setAddedBy(1);  
        return repo.addConcession(c);
    }

    public boolean updateConcession(Concession c) {
        return repo.updateConcession(c);
    }

    public boolean deleteConcession(int id) {
        return repo.deleteConcession(id);
    }
}