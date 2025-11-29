import express from 'express';
import {
  getFlights,
  getFlightById,
  createFlight,
  updateFlight,
  deleteFlight,
} from '../controllers/flightController.js';

const router = express.Router();

router.get('/', getFlights);
router.get('/:id', getFlightById);
router.post('/', createFlight);
router.put('/:id', updateFlight);
router.delete('/:id', deleteFlight);

export default router;

