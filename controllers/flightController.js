import { flights as initialFlights } from '../data/flights.js';
import { validateFlight } from '../utils/validators.js';

// In-memory data store (simulating database)
let flights = [...initialFlights];
let nextId = Math.max(...flights.map(f => f.id)) + 1;

// Get all flights with filtering and sorting
export const getFlights = (req, res) => {
  try {
    let filteredFlights = [...flights];

    // Filter by type
    if (req.query.type && req.query.type !== 'All') {
      filteredFlights = filteredFlights.filter(f => f.type === req.query.type);
    }

    // Filter by airline
    if (req.query.airline && req.query.airline !== 'All') {
      filteredFlights = filteredFlights.filter(f => f.airline === req.query.airline);
    }

    // Filter by status
    if (req.query.status && req.query.status !== 'All') {
      filteredFlights = filteredFlights.filter(f => f.status === req.query.status);
    }

    // Search by flight number (case-insensitive)
    if (req.query.q) {
      const searchTerm = req.query.q.toLowerCase();
      filteredFlights = filteredFlights.filter(f =>
        f.flightNumber.toLowerCase().includes(searchTerm)
      );
    }

    // Sort
    if (req.query.sortBy === 'scheduledTime') {
      filteredFlights.sort((a, b) => {
        const timeA = new Date(a.scheduledTime).getTime();
        const timeB = new Date(b.scheduledTime).getTime();
        if (req.query.order === 'desc') {
          return timeB - timeA;
        }
        return timeA - timeB;
      });
    }

    res.json(filteredFlights);
  } catch (error) {
    res.status(500).json({ message: 'Internal server error', error: error.message });
  }
};

// Get single flight by ID
export const getFlightById = (req, res) => {
  try {
    const id = parseInt(req.params.id);
    const flight = flights.find(f => f.id === id);

    if (!flight) {
      return res.status(404).json({ message: 'Flight not found' });
    }

    res.json(flight);
  } catch (error) {
    res.status(500).json({ message: 'Internal server error', error: error.message });
  }
};

// Create new flight
export const createFlight = (req, res) => {
  try {
    const validation = validateFlight(req.body, false);

    if (!validation.isValid) {
      return res.status(400).json({
        message: 'Validation failed',
        errors: validation.errors,
      });
    }

    const newFlight = {
      id: nextId++,
      flightNumber: req.body.flightNumber.trim(),
      airline: req.body.airline.trim(),
      type: req.body.type,
      origin: req.body.origin.trim().toUpperCase(),
      destination: req.body.destination.trim().toUpperCase(),
      scheduledTime: new Date(req.body.scheduledTime).toISOString(),
      gate: req.body.gate ? req.body.gate.trim() : '',
      status: req.body.status,
    };

    flights.push(newFlight);
    res.status(201).json(newFlight);
  } catch (error) {
    res.status(500).json({ message: 'Internal server error', error: error.message });
  }
};

// Update flight
export const updateFlight = (req, res) => {
  try {
    const id = parseInt(req.params.id);
    const flightIndex = flights.findIndex(f => f.id === id);

    if (flightIndex === -1) {
      return res.status(404).json({ message: 'Flight not found' });
    }

    const existingFlight = flights[flightIndex];
    const updatedData = { ...existingFlight, ...req.body };

    const validation = validateFlight(updatedData, false);

    if (!validation.isValid) {
      return res.status(400).json({
        message: 'Validation failed',
        errors: validation.errors,
      });
    }

    const updatedFlight = {
      ...updatedData,
      flightNumber: updatedData.flightNumber.trim(),
      airline: updatedData.airline.trim(),
      origin: updatedData.origin.trim().toUpperCase(),
      destination: updatedData.destination.trim().toUpperCase(),
      scheduledTime: new Date(updatedData.scheduledTime).toISOString(),
      gate: updatedData.gate ? updatedData.gate.trim() : '',
    };

    flights[flightIndex] = updatedFlight;
    res.json(updatedFlight);
  } catch (error) {
    res.status(500).json({ message: 'Internal server error', error: error.message });
  }
};

// Delete flight
export const deleteFlight = (req, res) => {
  try {
    const id = parseInt(req.params.id);
    const flightIndex = flights.findIndex(f => f.id === id);

    if (flightIndex === -1) {
      return res.status(404).json({ message: 'Flight not found' });
    }

    flights.splice(flightIndex, 1);
    res.status(204).send();
  } catch (error) {
    res.status(500).json({ message: 'Internal server error', error: error.message });
  }
};

