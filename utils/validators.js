const VALID_TYPES = ['Departure', 'Arrival'];
const VALID_STATUSES = ['On Time', 'Delayed', 'Boarding', 'Cancelled', 'Landed'];

export function validateFlight(data, isUpdate = false) {
  const errors = {};

  // Required fields
  if (!isUpdate || data.flightNumber !== undefined) {
    if (!data.flightNumber || data.flightNumber.trim() === '') {
      errors.flightNumber = 'Flight Number is required';
    } else if (!/^[A-Z0-9]+$/.test(data.flightNumber.trim())) {
      errors.flightNumber = 'Flight Number must be alphanumeric';
    }
  }

  if (!isUpdate || data.airline !== undefined) {
    if (!data.airline || data.airline.trim() === '') {
      errors.airline = 'Airline is required';
    }
  }

  if (!isUpdate || data.type !== undefined) {
    if (!data.type || !VALID_TYPES.includes(data.type)) {
      errors.type = `Type must be one of: ${VALID_TYPES.join(', ')}`;
    }
  }

  if (!isUpdate || data.origin !== undefined) {
    if (!data.origin || data.origin.trim() === '') {
      errors.origin = 'Origin is required';
    } else if (data.origin.trim().length !== 3) {
      errors.origin = 'Origin must be 3 characters (IATA code)';
    }
  }

  if (!isUpdate || data.destination !== undefined) {
    if (!data.destination || data.destination.trim() === '') {
      errors.destination = 'Destination is required';
    } else if (data.destination.trim().length !== 3) {
      errors.destination = 'Destination must be 3 characters (IATA code)';
    }
  }

  if (!isUpdate || data.scheduledTime !== undefined) {
    if (!data.scheduledTime) {
      errors.scheduledTime = 'Scheduled Time is required';
    } else {
      const date = new Date(data.scheduledTime);
      if (isNaN(date.getTime())) {
        errors.scheduledTime = 'Scheduled Time must be a valid date';
      }
    }
  }

  if (!isUpdate || data.status !== undefined) {
    if (!data.status || !VALID_STATUSES.includes(data.status)) {
      errors.status = `Status must be one of: ${VALID_STATUSES.join(', ')}`;
    }
  }

  return {
    isValid: Object.keys(errors).length === 0,
    errors,
  };
}

